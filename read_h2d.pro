function read_h2d, filename
    
    ;; This program reads in 7 variables from the netCDF output of
    ;; Hyades2D: r, z, rho, te, ti, tr, pres
    ;; 
    ;; Note that the variables in the CDF file are user-selectable,
    ;; i.e. only some subset (including null) of the 7 above is 
    ;;      necessary.  For this program to work, ALL of the variables
    ;;      must be present.
    ;;      
    ;; Input:
    ;;         filename -- (string) name of netCDF data file
    ;;
    ;; Returns:
    ;;         ptr to h2d object, contains runinfo, dimensions, and
    ;;         variables
    ;;
    ;; --David Chin, 9 Jul 1999
    ;;
    ;; $Id: read_h2d.pro,v 1.1.1.1 1999/09/03 14:32:03 dwchin Exp $
    ;;
    
    ;; Open netCDF file, and read global info
    
    cdfid = ncdf_open(filename)
    glob  = ncdf_inquire(cdfid)
    
    ;;
    ;; Define structures for dimensions
    ;; (automatic structure definition: see dim__define.pro)
    ;;
    num_klines = {dim}          ; number of axial nodes
    num_llines = {dim}          ; number of radial nodes
    num_nodes =  {dim}          ; total number of nodes
    num_regs  =  {dim}
    num_mats  =  {dim}
    num_times =  {dim}
    num_static_values = {dim}
    
    dimensions = {dimensions_struct, $
                  num_klines: num_klines, $
                  num_llines: num_llines, $
                  num_nodes:  num_nodes, $
                  num_regs:   num_regs, $
                  num_mats:   num_mats, $
                  num_times:  num_times, $
                  num_static_values: num_static_values}
    
    ;; Set dimension values from netCDF file
    
    num_klines.id = ncdf_dimid(cdfid, 'NumKLines')
    ncdf_diminq, cdfid, num_klines.id, name, size
    num_klines.name = name
    num_klines.size = size
    
    num_llines.id = ncdf_dimid(cdfid, 'NumLLines')
    ncdf_diminq, cdfid, num_llines.id, name, size
    num_llines.name = name
    num_llines.size = size
    
    num_nodes.id = ncdf_dimid(cdfid, 'NumNodes')
    ncdf_diminq, cdfid, num_nodes.id, name, size
    num_nodes.name = name
    num_nodes.size = size
    
    num_regs.id = ncdf_dimid(cdfid, 'NumRegs')
    ncdf_diminq, cdfid, num_regs.id, name, size
    num_regs.name = name
    num_regs.size = size
    
    num_mats.id = ncdf_dimid(cdfid, 'NumMats')
    ncdf_diminq, cdfid, num_mats.id, name, size
    num_mats.name = name
    num_mats.size = size
    
    num_times.id = ncdf_dimid(cdfid, 'NumTimes')
    ncdf_diminq, cdfid, num_times.id, name, size
    num_times.name = name
    num_times.size = size
    
    num_static_values.id = ncdf_dimid(cdfid, 'NumStaticValues')
    ncdf_diminq, cdfid, num_static_values.id, name, size
    num_static_values.name = name
    num_static_values.size = size
    
    
    ;;
    ;; Define structures for "meta" data. Contains run information.
    ;;
    
    ;; Run information
    varid = ncdf_varid(cdfid, 'Header')
    info = ncdf_varinq(cdfid, varid)
    ncdf_varget, cdfid, varid, value
    ncdf_attget, cdfid, varid, 'Namep', run_name
    ncdf_attget, cdfid, varid, 'Dbuf', run_date
    ncdf_attget, cdfid, varid, 'Tbuf', run_time
    ncdf_attget, cdfid, varid, 'Iver1', version
    ncdf_attget, cdfid, varid, 'Iver2', vers_date
    ncdf_attget, cdfid, varid, 'Machine', machine
    
    header = {header_struct, $
              name: info.name,  $ 
              run_name: strcompress(string(run_name)), $
              run_date: string(run_date),  $
              run_time: string(run_time), $
              version: string(version),  $
              vers_date: string(vers_date), $
              machine: string(machine)}
    
    
    ;; Names of data arrays
    varid = ncdf_varid(cdfid, 'ArrayNames')
    info = ncdf_varinq(cdfid, varid)
    ncdf_varget, cdfid, varid, value
    
    array_names = {array_names_struct, $
                   name: info.name,  $
                   names: string(value)}
    
    
    ;; DumpTimes
    varid = ncdf_varid(cdfid, 'DumpTimes')
    info = ncdf_varinq(cdfid, varid)
    ncdf_varget, cdfid, varid, value
    ncdf_attget, cdfid, varid, 'units', units
    
    dump_times = {dump_times_struct, $
                  name: info.name,  $
                  units: string(units),  $
                  value_ptr: ptr_new(value, /no_copy)}
    
    ;; Put header, array_names, and dump_times into a single structure
    ;; to facilitate passing as parameter
    runinfo = {runinfo_struct, $
               header: header,  $
               array_names: array_names,  $
               dump_times: dump_times}
    
    ;;
    ;; Create data objects. See data__define.pro
    ;;
    
    ;; R
    varid = ncdf_varid(cdfid, 'R')
    r = obj_new('data', cdfid, varid, num_klines, num_llines, num_times)
    
    ;; Z
    varid = ncdf_varid(cdfid, 'Z')
    z = obj_new('data', cdfid, varid, num_klines, num_llines, num_times)
    
    ;; Rho
    varid = ncdf_varid(cdfid, 'Rho')
    rho = obj_new('data', cdfid, varid, num_klines, num_llines, num_times)
    
    ;; Te
    varid = ncdf_varid(cdfid, 'Te')
    te = obj_new('data', cdfid, varid, num_klines, num_llines, num_times)
    
    ;; Ti
    varid = ncdf_varid(cdfid, 'Ti')
    info = ncdf_varinq(cdfid, varid)
    ti = obj_new('data', cdfid, varid, num_klines, num_llines, num_times)
    
    ;; Tr
    varid = ncdf_varid(cdfid, 'Tr')
    tr = obj_new('data', cdfid, varid, num_klines, num_llines, num_times)
    
    ;; Pres
    varid = ncdf_varid(cdfid, 'Pres')
    pres = obj_new('data', cdfid, varid, num_klines, num_llines, num_times)
    
    ;; Structure of variables: simple aggregate
    variables = {variables_struct, $
                 r: r, $        ; radial coordinate
                 z: z, $        ; axial coordinate
                 rho: rho, $    ; density
                 te: te, $      ; electron temperature
                 ti: ti, $      ; ion temperature
                 tr: tr, $      ; radiation temperature
                 pres: pres}    ; pressure
    
    ;; DEBUGGINNG
;    print, 'READ_H2D:'
;    help, runinfo.dump_times, /struct
;    help, dimensions, variables
    
    ;; Return new h2d object.
    return, obj_new('h2d', runinfo, dimensions, variables)
end
