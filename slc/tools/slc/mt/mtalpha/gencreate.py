from ...visitors import ScopedVisitor, flatten
from ...ast import *
from ...msg import warn
from regdefs import regmagic

class Create_2_MTACreate(ScopedVisitor):

    def visit_seta(self, seta):
        b = seta.rhs.accept(self)
        
        name = seta.name

        adic = seta.lowcreate.callconv
        fidvar = seta.lowcreate.fidvar
        rfidvar = seta.lowcreate.seta_rfidvar
        fdattr = seta.lowcreate.seta_fdattr
        
        if fdattr is not None:
        	fdname = fdattr.faultdetection
        
        # print "looking up %s in %r" % (name, self.__args)
        assert name in adic
        
        a = adic[name]
        
        newbl = []
        if a['mode'] == 'mem':
            mavar = seta.lowcreate.mavar
            newbl.append(flatten(seta.loc, '(') +
                         mavar + ').%s = ' % name +
                         CVarSet(decl = seta.decl.cvar, rhs = b))
        else:
            ctype = a['ctype']
            cat = a['cat']
            if cat == 'sh': 
                insn = 'puts'
                assign = b
            else: 
                assign = CVarSet(decl = seta.decl.cvar, rhs = b)
                insn = 'putg'
            if a['species'] == 'f': 
                insn = 'f' + insn
                rspec = 'f'
            else: rspec = 'rI'
            regnr = a['regnr']
            newbl.append(flatten(seta.loc, 
                                ' __asm__ ("%(insn)s %%2, %%0, %(regnr)d\\t# MT: set %(cat)sarg of master start thread"'
                                 ' : "=r"(' % locals()) +
                         fidvar + ') : "0"(' + fidvar + 
                         '), "%s"((' % rspec + ctype + ')(' +
                         assign + ')));')
            if (fdattr is not None) and (fdname == 'start'):
            	newbl.append(flatten(seta.loc, 
                                ' __asm__ ("%(insn)s %%2, %%0, %(regnr)d\\t# MT: set %(cat)sarg of redundant start thread"'
                                 ' : "=r"(' % locals()) +
                         rfidvar + ') : "0"(' + rfidvar + 
                         '), "%s"((' % rspec + ctype + ')(' +
                         assign + ')));')
        return newbl
                  

    def visit_lowcreate(self, lc):


        #print "IN LOWC (v = %x, d = %x, lc = %x)" % (id(self), id(self.__dict__), id(lc))
        cr = self.cur_scope.creates[lc.label]



        # compute the calling convention
        c = regmagic.mapcall(cr.args, funcname = "create", loc = cr.loc)

        newbl = Block(loc = cr.loc)
        lbl = cr.label

        # generate allocate + test for alternative
        fidvar = cr.cvar_fid
        start = CVarUse(decl = cr.cvar_start)
        limit = CVarUse(decl = cr.cvar_limit)
        step = CVarUse(decl = cr.cvar_step)
        block = CVarUse(decl = cr.cvar_block)
        
        usefvar = CVarUse(decl = fidvar)
        
        strategyuse = CVarUse(cr.cvar_strategy)
        
        rfidvar = CVarUse(decl = cr.cvar_rfid)
        
        fdattr = cr.extras.get_attr('faultdetection', None)

        if cr.extras.has_attr('exclusive'):
            allocinsn = 'allocate/x'
        elif lc.target_next is None:
            if cr.extras.has_attr('nowait'):
                warn("this create may fail and no alternative is available", cr)
                allocinsn = 'allocate'
            else:
                allocinsn = 'allocate/s'
        else:
            if cr.extras.has_attr('forcewait'):
                allocinsn = 'allocate/s'
            else:
                allocinsn = 'allocate'
        
        if fdattr is None:
        	newbl += (flatten(cr.loc,
        				"""__asm__ __volatile__("%(allocinsn)s %%2, %%1, %%0\\t#MT: CREATE %(lbl)s" """ % locals()) +
        										' : "=r"(' + usefvar + ')' +
        										' : "rI"(' + strategyuse + '), "r"(' + CVarUse(decl = cr.cvar_place) + '));')
        
        else:
        	fdname = fdattr.faultdetection
        	
        	if fdname == 'start':
        		newbl += (flatten(cr.loc,
        					"""__asm__ __volatile__("%(allocinsn)s %%4, %%2, %%0;"
        											"%(allocinsn)s %%4, %%3, %%1;"
        											"pair %%0, %%1;"
        											"pair %%1, %%0\\t#MT: REDUNDANT CREATE START %(lbl)s" """ % locals()) +
        											' : "=r&"(' + usefvar + '), "=r"(' + rfidvar + ')' +
        											' : "rI"(' + strategyuse + '|' + '8' + '), "rI"(' + strategyuse + '|' + '12' + '), "r"(' + CVarUse(decl = cr.cvar_place) + '));')
        
        	elif fdname == 'redundancy':
        		if allocinsn == 'allocate':
        			allocrinsn = 'allocate/r'
        		elif allocinsn == 'allocate/s':
        			allocrinsn = 'allocate/rs'
        		else:
        			allocrinsn = 'allocate/rx'
        			
        		newbl += (flatten(cr.loc,
        					"""__asm__ __volatile__("%(allocinsn)s %%3, %%2, %%0;"
        											"%(allocrinsn)s %%3, %%2, %%1;"
        											"pair %%0, %%1;"
        											"pair %%1, %%0;"
        											"rmtwr %%1\\t#MT: REDUNDANT CREATE SCOPE %(lbl)s" """ % locals()) +
        											' : "=r&"(' + usefvar + '), "=r"(' + rfidvar + ')' +
        											' : "rI"(' + strategyuse + '), "r"(' + CVarUse(decl = cr.cvar_place) + '));')
        
        
        
        if lc.target_next is not None:
        	newbl += (flatten(cr.loc, ' if (!__builtin_expect(!!(') + usefvar + '), 1)) ' + CGoto(target = lc.target_next)) + ';'
        	if (fdattr is not None) and (fdname == 'start'):
        		newbl += (flatten(cr.loc, ' if (!__builtin_expect(!!(') + rfidvar + '), 1)) ' + CGoto(target = lc.target_next)) + ';' 
        	
            

        # generate the function pointer
        if cr.funtype == cr.FUN_ID:
            if lc.lowfun is not None:
                funvar = lc.lowfun
            else:
                # not yet split
                funvar = Opaque(cr.fun)
        else:
            assert cr.funtype == cr.FUN_VAR

            n = 'C$mtF$%s' % lbl
            t = 'C$mtF$%s' % lbl
            
            thetype = CTypeDecl(loc = cr.loc,
                                name = t,
                                ctype = CType(items = 
                                              Opaque(text = "void (*") +
                                              CTypeHead() + 
                                              ')(void)'))
            self.cur_scope.decls += thetype
            funvar = CVarDecl(loc = cr.loc, name = n, ctype = CTypeUse(tdecl = thetype))
            self.cur_scope.decls += funvar

            if lc.lowfun is not None:
                thefun = lc.lowfun
            else:
                # not yet split
                thefun = CVarUse(decl = cr.fun)

            newbl += CVarSet(loc = cr.loc, decl = funvar, 
                             rhs = CCast(ctype = CTypeUse(tdecl = thetype),
                                         expr = thefun)) + ';'
            funvar = CVarUse(decl = funvar)

        # prepare memory structure for memory-passed arguments
            ### FIXME: move stuff to cur_scope
        if c['gl_mem_offset'] is not None:
            maname = "C$mtM$%s" % lbl
            mat = 'C$mtM$%s' % lbl

            thestruct = Opaque('struct {')
            for d in c['memlayout']:
                thestruct = thestruct + (Opaque(loc = d['loc']) + d['ctype'] + ' ' + d['name'] + ';')
            thestruct = thestruct + '}'

            thetype = CTypeDecl(loc = cr.loc,
                                name = mat,
                                ctype = thestruct)

            self.cur_scope.decls += thetype
            mavar = CVarDecl(loc = cr.loc, name = maname, ctype = CTypeUse(tdecl = thetype))
            self.cur_scope.decls += mavar
            mavar = CVarUse(decl = mavar)
            lc.mavar = mavar

        # generate create 
        if (fdattr is not None) and (fdname == 'start'):
        	newbl += (flatten(cr.loc, 
        					'__asm__ ("setstart %%0, %%2\\t# MT: REDUNDANT CREATE START (master) %s"'
        						' : "=r"(' % lbl) +
        						usefvar + ') : "0"(' + usefvar + '), "rI"(' + start + ')); ' +
        					'__asm__ ("setstart %%0, %%2\\t# MT: REDUNDANT CREATE START (redundant) %s"' % lbl +
        						' : "=r"(' + rfidvar + ') : "0"(' + rfidvar  + '), "rI"(' + start + ')); ' +
        					'__asm__ ("setlimit %%0, %%2\\t# MT: REDUNDANT CREATE START (master) %s"' % lbl +
        						' : "=r"(' + usefvar + ') : "0"(' + usefvar  + '), "rI"(' + limit + ')); ' +
        					'__asm__ ("setlimit %%0, %%2\\t# MT: REDUNDANT CREATE START (redundant) %s"' % lbl +
        						' : "=r"(' + rfidvar + ') : "0"(' + rfidvar  + '), "rI"(' + limit + ')); ' +
        					'__asm__ ("setstep %%0, %%2\\t# MT: REDUNDANT CREATE START (master) %s"' % lbl +
        						' : "=r"(' + usefvar + ') : "0"(' + usefvar + '), "rI"(' + step + ')); ' +
        					'__asm__ ("setstep %%0, %%2\\t# MT: REDUNDANT CREATE START (redundant) %s"' % lbl +
        						' : "=r"(' + rfidvar + ') : "0"(' + rfidvar + '), "rI"(' + step + ')); ' +
        					'__asm__ ("setblock %%0, %%2\\t# MT: REDUNDANT CREATE START (master) %s"' % lbl +
        						' : "=r"(' + usefvar + ') : "0"(' + usefvar + '), "rI"(' + block + ')); ' +
        					'__asm__ ("setblock %%0, %%2\\t# MT: REDUNDANT CREATE START (redundant) %s"' % lbl +
        						' : "=r"(' + rfidvar + ') : "0"(' + rfidvar + '), "rI"(' + block + ')); ' +
        					'__asm__ __volatile__("crei %%0, 0(%%2)\\t# MT: REDUNDANT CREATE START (master) %s"' % lbl +
        						' : "=r"(' + usefvar + ') : "0"(' + usefvar + '),' +
        						'   "r"(' + funvar + ') : "memory");' +
        					'__asm__ __volatile__("crei %%0, 0(%%2)\\t# MT: REDUNDANT CREATE START (redundant) %s"' % lbl +
        						' : "=r"(' + rfidvar + ') : "0"(' + rfidvar + '),' +
        						'   "r"(' + funvar + ') : "memory");')

        else: 
        	newbl += (flatten(cr.loc, 
                         	'__asm__ ("setstart %%0, %%2\\t# MT: CREATE %s"'
                         		' : "=r"(' % lbl) +
                  				usefvar + ') : "0"(' + usefvar + '), "rI"(' + start + ')); ' +
                  			'__asm__ ("setlimit %%0, %%2\\t# MT: CREATE %s"' % lbl +
                  				' : "=r"(' + usefvar + ') : "0"(' + usefvar  + '), "rI"(' + limit + ')); ' +
                  			'__asm__ ("setstep %%0, %%2\\t# MT: CREATE %s"' % lbl +
                  				' : "=r"(' + usefvar + ') : "0"(' + usefvar + '), "rI"(' + step + ')); ' +
                  			'__asm__ ("setblock %%0, %%2\\t# MT: CREATE %s"' % lbl +
                  				' : "=r"(' + usefvar + ') : "0"(' + usefvar + '), "rI"(' + block + ')); ' +
                  			'__asm__ __volatile__("crei %%0, 0(%%2)\\t# MT: CREATE %s"' % lbl +
                  				' : "=r"(' + usefvar + ') : "0"(' + usefvar + '),' +
                  				'   "r"(' + funvar + ') : "memory");')

        lc.callconv = c['nargs']
        lc.fidvar = usefvar
        lc.seta_rfidvar = rfidvar
        lc.seta_fdattr = fdattr

        newbl += lc.body.accept(self)


        # done with body, now handle sync

        # first of all, if there weresome memory-passed arguments,
        # we need to push the argument register to the child family.
        # A memory barrier is required because the remote thread(s) may
        # access the memory as soon as putg completes.
        
        if c['gl_mem_offset'] is not None:
        	if (fdattr is not None) and (fdname == 'start'):
        		newbl += (flatten(cr.loc_end, 
                		        ' __asm__ ("wmb; putg %%2, %%0, %d\\t#MT: set offset for memargs (master)"' 
                    	    	   	  % c['gl_mem_offset']) + 
                      				' : "=r"(' + usefvar + ') : "0"(' + usefvar + '),' +
                      				'   "r"(&' + mavar + '));' +
                      			' __asm__ ("wmb; putg %%2, %%0, %d\\t#MT: set offset for memargs (redundant)"' 
                    	       		  % c['gl_mem_offset'] + 
                      				' : "=r"(' + rfidvar + ') : "0"(' + rfidvar + '),' +
                      				'   "r"(&' + mavar + '));')

        	else:
        		newbl += (flatten(cr.loc_end,
        						' __asm__ ("wmb; putg %%2, %%0, %d\\t#MT: set offset for memargs"' 
        							% c['gl_mem_offset']) +
        							' : "=r"(' + usefvar + ') : "0"(' + usefvar + '),' +
        							'   "r"(&' + mavar + '));')

        # now, on to the sync.
        if cr.sync_type == 'normal':
            # normal, synchronized create

            # first wait for child family to terminate.
            newbl += (flatten(cr.loc_end, 
                             '__asm__ __volatile__("sync %%0, %%1; '
                             ' mov %%1, $31\\t# MT: SYNC %s"' % lbl) +
                      ' : "=r"(' + usefvar + '), "=r"(' + 
                      CVarUse(decl = cr.cvar_exitcode) + 
                      ') : "0"(' + usefvar + ') : "memory");')
            
            # then pull shared arguments back.
            for name, arg in c['nargs'].iteritems():
                crarg = cr.arg_dic[name]
                if not crarg.seen_get:
                    # geta() is not used, so no need to retrieve
                    continue
                if arg['mode'] == 'reg' and arg['cat'] == 'sh':
                    if arg['species'] == 'f':
                        insn1 = 'fgets'
                        insn2 = 'fmov'
                        rspec = 'f'
                    else:
                        insn1 = 'gets'
                        insn2 = 'mov'
                        rspec = 'r'
                    regnr = arg['regnr']
                    argvar = crarg.cvar
                    # FIXME: perform "mov" after all "get" have been issued!
                    newbl += (flatten(cr.loc_end, 
                                     ' __asm__ ('
                                     '"%(insn1)s %%0, %(regnr)d, %%1; '
                                     ' %(insn2)s %%1, %%1'
                                     '\\t# MT: get shared"' % locals()) +
                              ' : "=r"(' + usefvar + '), "=%(rspec)s"(' % locals() +
                              CVarUse(decl = argvar) + ') : "0"(' + usefvar + '));')
    
                          
        if cr.sync_type != 'spawn':
            # for normal sync and detach, release resources.
            # spawn will sync+release later.
            if (fdattr is not None) and (fdname == 'start'):
            	newbl += (flatten(cr.loc_end, 
								' __asm__ __volatile__("release %%0\\t#MT: SYNC (master) %s"' % lbl) +
                      				' : : "r"(' + usefvar + '));' +
                      			' __asm__ __volatile__("release %%0\\t#MT: SYNC (redundant) %s"' % lbl +
                      				' : : "r"(' + rfidvar + '));')
            else:
            	newbl += (flatten(cr.loc_end, 
                              ' __asm__ __volatile__("release %%0\\t#MT: SYNC %s"' % lbl) +
                      ' : : "r"(' + usefvar + '));')

        return newbl



__all__ = ['Create_2_MTACreate']
