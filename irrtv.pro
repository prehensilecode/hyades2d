pro irrtv, data, x, y, datarange=datarange, xrange=xrange, yrange=yrange,  $
           title=title, xtitle=xtitle, ytitle=ytitle,  $
           nogrid=nogrid, contour=contour, nofill=nofill, _extra=extra
    
    ;;
    ;; Paints in polygons.
    ;; data, x, y, are 2D arrays
    ;; x, y contain coordinates of data
    ;; (uses colorbar.pro by D. Fanning)
    ;;
    ;;                      -- David Chin, 26 July 1999
    ;;
    ;; $Id: irrtv.pro,v 1.1.1.1 1999/09/03 14:32:03 dwchin Exp $
    ;;
    
    ;; The datarange keyword is useful for making many plots with the
    ;; same range, especially for animating.
    if not keyword_set(datarange) then datarange = [min(data), max(data)]
    
    ;; Check for "bowtie": min(datarange) > max(datarange)
    if datarange[0] gt datarange[1] then begin
        
        result = dialog_message('IRRTV: bowtie occured', _extra=extra, $
                                title='IRRTV error')
        
    endif else begin
        
        if not keyword_set(contour) then begin
            ;;
            ;; Polygon plot
            ;;
            
            ;; set data coordinates with empty plot
            plot, [0., 0.], xrange=xrange, yrange=yrange,  $
              xtitle=xtitle, ytitle=ytitle, title=title, $
              position=[.13, .17, .66, .9], /normal, /nodata
            
            dims = (size(data))[1:2] ; dims[0] = number of cols (x)
                                ; dims[1] = number of rows (y)
            
            ;; Assume 4-sided polygons
            ;; Will have (dims[0] - 1) * (dims[1] - 1) number of polygons
            npolys = [dims[0]-1, dims[1]-1]
            poly = lonarr(4,2,npolys[0]*npolys[1]) ; index-coords of polygons
            tmpdata = dblarr(npolys[0], npolys[1]) ; tmp array for data
            
            for j=0,npolys[1]-1 do begin
                for i=0,npolys[0]-1 do begin
                    poly[*, *, npolys[0]*j+i] = [ [i, i+1, i+1, i],  $
                                                  [j, j,   j+1, j+1] ]
                    
                    tmpdata[i,j] = (data[i,   j] + data[i,   j+1] +  $
                                    data[i+1, j] + data[i+1, j+1])/4.
                endfor
            endfor
            
            ;; Scale data into range [0, 99]
            tmpdata = bytscl(tmpdata,  $
                             min=datarange[0], max=datarange[1], $
                             top=99)
            
            ;; tmpx and tmpy will store coordinates of current polygon
            tmpx = fltarr(4)
            tmpy = fltarr(4)
            totnpolys = npolys[0]*npolys[1]
            for i=0,totnpolys-1 do begin
                for j=0,1 do begin
                    for k=0,1 do begin
                        tmpx[j+2*k] = x[poly[j+2*k,0,i], poly[j+2*k,1,i]]
                        tmpy[j+2*k] = y[poly[j+2*k,0,i], poly[j+2*k,1,i]]
                    endfor
                endfor
                
                ;; fill in polygon with color from scaled data
                polyfill, tmpx, tmpy, color=tmpdata[i]
            endfor
            
            if not keyword_set(nogrid) then begin
                irrgrid, x, y   ; draw grid of polygons
            endif else begin
                irrgrid, x, y, /outline ; draw only the outline
            endelse
            
        endif else begin
            ;;
            ;; Contour plot
            ;;
            
            ;; Scale data into range [0, 99]
            tmpdata = bytscl(data,  $
                             min=datarange[0], max=datarange[1], $
                             top=99)
            
            tmprange = bytscl(datarange)
            
            nlevels = 10        ; number of levels for contours
            levels = fltarr(nlevels) ; array of levels
            range = tmprange[1] - tmprange[0]
            for i=0,nlevels-1 do begin
                levels[i] = range*(i+1)/nlevels + tmprange[0]
            endfor
            
            ;; DEBUGGING
            ;;print, tmprange
            ;;print, levels
            
            if not keyword_set(nofill) then begin
                ;;
                ;; Filled contours
                ;;
                
                contour, tmpdata, x, y, xrange=xrange, yrange=yrange,  $
                  xtitle=xtitle, ytitle=ytitle, title=title, $
                  position=[.13, .17, .66, .9], /normal, /fill,  $
                  levels=levels, c_colors=levels
                
                contour, tmpdata, x, y, /overplot, levels=levels, $
                  _extra=extra
                
            endif else begin
                ;;
                ;; Unfilled contours; annotated
                ;;
                
                lev = fltarr(nlevels)
                for i=0,nlevels-1 do begin
                    lev[i] = (datarange[1] - datarange[0])*(i+1)/nlevels +  $
                      datarange[0]
                endfor
                
                ;; Annotate level with value of level
                anno = string(format='(f10.2)', lev)
                
                contour, tmpdata, x, y, xrange=xrange, yrange=yrange,  $
                  xtitle=xtitle, ytitle=ytitle, title=title, $
                  position=[.13, .17, .66, .9], /normal,  $
                  levels=levels, c_annotation=anno
                
            endelse
            
            irrgrid, x, y, /outline ; draw outline
        endelse
        
        ;; Put in colorbar
        colorbar, /vertical,  $
          range=exp(datarange * alog(10.)), format='(e10.2)', $
          position=[.75, .17, .8, .9], /right
        
    endelse
    
end

@irrgrid
