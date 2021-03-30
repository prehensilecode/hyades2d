;; Class "data" methods and structure.
;;
;;            -- David Chin, 9 Jul 1999
;;
;; $Id: data__define.pro,v 1.1.1.1 1999/09/03 14:32:03 dwchin Exp $
;;

@irrtv

function data::init, cdfid, varid, num_klines, num_llines, num_times
    
    ;;
    ;; Constructor for the class "data"
    ;;
    
    ;; Get info from netCDF file
    info = ncdf_varinq(cdfid, varid)
    
    ;; Read information into variables: value, units, long_name
    ncdf_readdata, cdfid, varid, value, units, long_name
    
    self.name       = info.name
    self.long_name  = string(long_name)
    self.id         = varid
    self.units      = string(units)
    self.num_klines = num_klines.size
    self.num_llines = num_llines.size
    self.num_times  = num_times.size
    
    
    ;; Create a temporary array, and fill it with data
    tmp = dblarr(self.num_klines,  $
                 self.num_llines,  $
                 self.num_times)
    
    for i=0,self.num_times-1 do begin
        tmp[*,*,i] = [value[0:self.num_klines-1, i],  $
                             value[self.num_klines:*, i]]
    endfor
    
    self.value_ptr = ptr_new(tmp, /no_copy)
    
    return, 1
end


;;====================================================================


pro data::cleanup
    
    ;;
    ;; "Data" object destructor.
    ;;
    
    ;; Free the pointer to matrix of data
    ptr_free, self.value_ptr
    
end

;;====================================================================


pro ehandler, event
    
    ;; Bare-bones event handler for cw_animate in data::animate
    
    widget_control, /destroy, event.top
    
end


;;====================================================================


pro data::animate, runinfo, r, z, group_leader=group, _extra=extra
    
    ;; Runs animation of variable vs. r and z
    
    ;; Get arrays of coordinates for each mesh point
    r_array = r->getValue()
    z_array = z->getValue()
    
    winsize = [400L, 300L]      ; window size
    
    pwin = replicate(-1, self.num_times) ; array of pixmap window IDs
    
    ;; Ranges of coordinates
    r_range = [min(r_array), max(r_array)]
    z_range = [min(z_array), max(z_array)]
    
    ;; Temporary array to store value of data.  Needed since we'll
    ;; have to mangle this a little: assume that memory is cheaper
    ;; than CPU cycles.
    tmparray = alog10(*self.value_ptr)
    datarange = [min(tmparray), max(tmparray)]
    
    ;; Plot frames to "hidden" windows (pixmaps)
    for i=0,self.num_times-1 do begin
        window, /free, xsize=winsize[0], ysize=winsize[1], /pixmap
        pwin[i] = !d.window
        
        ;; irrtv colors each zone by averaging over the 4 mesh points
        ;; defining the zone
        irrtv, tmparray[*,*,i],  $
          z_array[*,*,i], r_array[*,*,i],  $
          datarange=datarange,  $
          xrange=z_range, yrange=r_range,  $
          xtitle=z.name+' ('+z.units+')',  $
          ytitle=r.name+' ('+r.units+')',  $
          title=self.long_name+' ('+self.units+')', $
          _extra=extra
    endfor
    
    ;; Set up widgets
    base = widget_base(title=runinfo.header.run_name+': '+self.long_name)
    widget_control, /managed, base
    widget_control, /realize, base
    
    anim = cw_animate(base, winsize[0], winsize[1], self.num_times,  $
                      pixmaps=pwin)
    
    ;; Run the animation
    cw_animate_run, anim, 30
    
    xmanager, 'H2Danimation', base, event_handler='ehandler',  $
      group_leader=group, /no_block
    
end


;;====================================================================


pro data::animZone, runinfo, group_leader=group
    
    ;; Runs animation of log(variable) vs. zone
    ;; Simply interpret data at each time step as an image.
    
    ;; Set size of plot window
    scale_factor = 20           
    
    ;; Set up the cw_animate built-in complex widget
    base = widget_base(title=runinfo.header.run_name+': '+ $
                       self.long_name+' (Zones)') 
    anim = cw_animate(base,  $
                      scale_factor*self.num_klines,  $
                      scale_factor*self.num_llines,  $
                      self.num_times, $
                      pixmaps=pixmap_vect)
    
    ;; hourglass cursor while waiting for pixmaps to load
    widget_control, /realize, base, /hourglass 
    
    logvarmin = alog10(min(*self.value_ptr))
    logvarmax = alog10(max(*self.value_ptr))
    
    ;; Load scaled images into cw_animate widget
    ;; Scale images into range [0, 99]
    for i=0,self.num_times-1 do begin
        cw_animate_load, anim, frame=i,  $
          image=congrid(bytscl(alog10((*self.value_ptr)[*,*,i]),  $
                               min=logvarmin, max=logvarmax, top=99),  $
                        scale_factor*self.num_klines,  $
                        scale_factor*self.num_llines)
    endfor

    ;; Save pixmaps from widget anim into pixmap_vect
    cw_animate_getp, anim, pixmap_vect
    
    ;; Run animation
    cw_animate_run, anim, 10
    
    xmanager, 'H2Danimation', base, event_handler='ehandler',  $
      group_leader=group, /no_block
end


;;====================================================================


function data::getName
    
    return, self.name
    
end


;;====================================================================


function data::getLongName
    
    return, self.long_name
    
end


;;====================================================================


function data::getUnits
    
    return, self.units
    
end


;;====================================================================


function data::getNumKLines
    
    return, self.num_klines
    
end


;;====================================================================


function data::getNumLLines
    
    return, self.num_llines
    
end


;;====================================================================


function data::getNumTimes
    
    return, self.num_times
    
end


;;====================================================================


pro data::printValue
    
    print, (*self.value_ptr)
    
end


;;====================================================================


function data::getValue
    
    return, (*self.value_ptr)
    
end


;;====================================================================


function data::getName
    
    return, self.name
    
end


;;====================================================================


function data::getLongName
    
    return, self.long_name
    
end


;;====================================================================


function data::getID
    
    return, self.id
    
end


;;====================================================================


function data::getUnits
    
    return, self.units
    
end


;;====================================================================


pro data::printInfo
    
    ;;
    ;; Print out information.
    ;;
    
    print, 'Name:      ', self->getName()
    print, 'Long name: ', self->getLongName()
    print, 'Units:     ', self->getUnits()
    print, 'Value: '
    help, self.value_ptr, /struct
    
end


;;====================================================================


pro data__define
    
    ;; Define the "data" structure for the "data" class
    
    ;; Use pointers to the actual data since we'd like to be
    ;; able to change data sets.
    
    ;; To understand this a little better, use ncdf_cat.pro to look at
    ;; the information contained in a netCDF file.
    
    ;; Each "data" object is an aggregate of a variable's data (a
    ;; matrix of doubles), and information about it.
    struct = {data,  $
              name: '',  $            ;;; name of the variable
              long_name: '',  $       ;;; descriptive name
              id: 0L,  $              ;;; ID number from netCDF file
              units: '', $            ;;; units of the variable
              num_klines: 0L,  $      ;;; see HYADES 2D manual regarding
              num_llines: 0L,  $      ;;; setup of mesh for klines and llines
              num_times: 0L,  $       ;;; no. of time steps dumped
              value_ptr: ptr_new()}   ;;; pointer to matrix of data
    
end
