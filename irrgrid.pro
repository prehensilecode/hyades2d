pro irrgrid, x, y, xrange=xrange, yrange=yrange, outline=outline,  $
             _extra=extra
    
    ;; Draws a grid over irregular points in 2D
    ;; x == x-coordinates
    ;; y == y-coordinates
    ;;
    ;; $Id: irrgrid.pro,v 1.1.1.1 1999/09/03 14:32:03 dwchin Exp $
    ;;
    
    ;; num_mesh == number of mesh points
    num_mesh = (size(x))[1:2]
    
    ;; DEBUGGING
    ;;print, num_mesh
    
    if not keyword_set(xrange) then begin
        xrange = [min(x), max(x)]
    endif
    
    if not keyword_set(yrange) then begin
        yrange = [min(y), max(y)]
    endif
    
    ;; The "vertical" lines
    ;;plot, x[0,*], y[0,*], psym=7, xrange=xrange, yrange=yrange
    
    ;;plot, x[0,*], y[0,*], xrange=xrange, yrange=yrange, /noerase
    oplot, x[0,*], y[0,*], _extra=extra
    
    if not keyword_set(outline) then begin
        for i=1,num_mesh[0]-1 do begin
            ;;oplot, x[i,*], y[i,*], psym=7
            oplot, x[i,*], y[i,*], _extra=extra
        endfor
    endif else begin
        oplot, x[num_mesh[0]-1,*], y[num_mesh[0]-1,*], _extra=extra
    endelse
    
    ;; The "horizontal" lines
    ;;oplot, x[*,0], y[*,0], psym=7
    oplot, x[*,0], y[*,0], _extra=extra
    
    if not keyword_set(outline) then begin
        for i=1,num_mesh[1]-1 do begin
            ;;oplot, x[*,i], y[*,i], psym=7
            oplot, x[*,i], y[*,i], _extra=extra
        endfor
    endif else begin
        oplot, x[*,num_mesh[1]-1], y[*,num_mesh[1]-1], _extra=extra
    endelse
    
end
