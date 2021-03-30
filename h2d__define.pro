;; Class "h2d" methods and structure.
;;
;; Class h2d aggregates all the variables from the HYADES 2D run
;; together, plus some information on the run.
;;            
;;             -- David Chin, 14 Jul 1999
;;
;; $Id: h2d__define.pro,v 1.1.1.1 1999/09/03 14:32:03 dwchin Exp $
;; 

function h2d::init, runinfo, dimensions, variables
    
    ;;
    ;; Class H2D constructor.
    ;;
    
    self.runinfo = runinfo
    self.dimensions = dimensions
    self.variables = variables
    
    ;; DEBUGGING
;    print, 'H2D::INIT:'
;    help, self.runinfo.dump_times, /struct
    
    return, 1
end


;;====================================================================


pro h2d::cleanup
    
    ;;
    ;; Class H2D destructor.
    ;;
    
    ;; Destroy all data objects.
    for i=0,n_tags(self.variables)-1 do begin
        obj_destroy, self.variables.(i)
    endfor
    
    ;; Free the pointer to array of dump times.
    ptr_free, self.runinfo.dump_times.value_ptr
    
end


;;====================================================================


function h2d::getVarObject, varname
    
    ;;
    ;; Access to the data objects.
    ;;
    
    case varname of
        'rho': return, self.variables.rho
        
        'te': return, self.variables.te
        
        'ti': return, self.variables.ti
        
        'tr': return, self.variables.tr
        
        'pres': return, self.variables.pres
        
        else: begin
            print, 'h2d::getVarObject: invalid variable ', varname
            return, -1
        end
    endcase
    
end


;;====================================================================


function h2d::getVarData, varname
    
    ;;
    ;; Access to the actual data (arrays of doubles)
    ;;
    
    case varname of
        'r': return, self.variables.r->getValue()
        
        'z': return, self.variables.z->getValue()
        
        'rho': return, self.variables.rho->getValue()
        
        'te': return, self.variables.te->getValue()
        
        'ti': return, self.variables.ti->getValue()
        
        'tr': return, self.variables.tr->getValue()
        
        'pres': return, self.variables.pres->getValue()
        
        else: begin
            print, 'h2d::getVarData: invalid variable ', varname
            return, -1
        end
    endcase
    
end


;;====================================================================


function h2d::getRunName
    
    return, self.runinfo.header.run_name
    
end


;;====================================================================


function h2d::getRunDate
    
    return, self.runinfo.header.run_date
    
end


;;====================================================================


function h2d::getRunTime
    
    return, self.runinfo.header.run_time
    
end


;;====================================================================


function h2d::getVarNames
    
    return, self.runinfo.array_names.names
    
end


;;====================================================================


function h2d::getDumpTimes

    return, *(self.runinfo.dump_times.value_ptr)
    
end


;;====================================================================


pro h2d::animate, varname, group_leader=group, _extra=extra
    
    ;;
    ;; Run position animation.
    ;;
    
    case varname of
        'rho': self.variables.rho->animate, self.runinfo,  $
          self.variables.r, self.variables.z, group_leader=group, $
          _extra=extra
        
        'te': self.variables.te->animate, self.runinfo,  $
          self.variables.r, self.variables.z, group_leader=group, $
          _extra=extra
        
        'ti': self.variables.ti->animate, self.runinfo,  $
          self.variables.r, self.variables.z, group_leader=group, $
          _extra=extra
        
        'tr': self.variables.tr->animate, self.runinfo,  $
          self.variables.r, self.variables.z, group_leader=group, $
          _extra=extra
        
        'pres': self.variables.pres->animate, self.runinfo,  $
          self.variables.r, self.variables.z, group_leader=group, $
          _extra=extra
        
        else: print, 'h2d::animate: invalid variable ', varname
    endcase
    
end


;;==================================================================


pro h2d::animZone, varname, group_leader=group
    
    ;;
    ;; Run zone animation
    ;;
    
    case varname of
        'rho': self.variables.rho->animZone, self.runinfo,  $
          group_leader=group
        
        'te': self.variables.te->animZone, self.runinfo,  $
          group_leader=group
        
        'ti': self.variables.ti->animZone, self.runinfo,  $
          group_leader=group
        
        'tr': self.variables.tr->animZone, self.runinfo,  $
          group_leader=group
        
        'pres': self.variables.pres->animZone, self.runinfo,  $
          group_leader=group
        
        else: print, 'h2d::animZone: invalid variable ', varname
    endcase
    
end


;;====================================================================


pro h2d::printRunInfo
    
    ;;
    ;; Print out run information.
    ;;
    
    print, 'Run name:  ', self->getRunName()
    print, 'Date:      ', self->getRunTime(), ' ', self->getRunDate()
    print, 'Variables: ', self->getVarNames()
    
end


;;====================================================================


pro h2d::printDebugInfo
    
    ;;
    ;; Print out debugging info on objects and structures.
    ;;
    
    help, self, /object
    help, self.runinfo, /struct
    help, self.dimensions, /struct
    help, self.variables, /struct
    
end


;;====================================================================


pro h2d__define
    
    ;;
    ;; Class h2d is an aggregate of data objects (all the data from
    ;; the H2D run), plus information about the run, and dimensions of
    ;; the variables.
    ;;
    
    ;; The component structures (runinfo_struct, dimensions_struct,
    ;; and variables_struct) are defined in read_h2d.pro
    struct = {h2d, $
              runinfo: {runinfo_struct}, $
              dimensions: {dimensions_struct}, $
              variables: {variables_struct}}
    
end
