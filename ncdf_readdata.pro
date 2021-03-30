pro ncdf_readdata, cdfid, varid, value, units, long_name
    
    ;;
    ;; Reads in value, units, and long_name for the variable with
    ;; varid "varid".
    ;;
    ;; Inputs:
    ;;        cdfid  --  ID of netCDF file
    ;;        varid  --  ID of netCDF variable of interest
    ;;
    ;; Outputs:
    ;;        value  --  (dblarr)  value of the variable
    ;;        units  --  (byte)  byte form of units (e.g. gm/cm^3)
    ;;        long_name  --  (byte)  long name for variable
    ;;        
    ;; $Id: ncdf_readdata.pro,v 1.1.1.1 1999/09/03 14:32:03 dwchin Exp $
    
    ncdf_varget, cdfid, varid, value
    ncdf_attget, cdfid, varid, 'units', units
    ncdf_attget, cdfid, varid, 'long_name', long_name
    
end
