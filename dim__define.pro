pro dim__define
    ;;
    ;; Definition of the dim structure
    ;;             -- David Chin, 9 Jul 1999
    ;;
    ;; $Id: dim__define.pro,v 1.1.1.1 1999/09/03 14:32:03 dwchin Exp $
    ;;
    
    struct = {dim,  $
              name: '',  $      ; name of this dimension
              id: 0L,  $        ; netCDF ID no. of this dimension
              size: 0L}         ; size of this dimension (value)
    
end
