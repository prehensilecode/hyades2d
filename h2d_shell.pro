;;
;; Program for looking at HYADES 2D output
;;                  -- David Chin, 9 Jul 1999
;;
;; $Id: h2d_shell.pro,v 1.1.1.1 1999/09/03 14:32:03 dwchin Exp $
;;

print, ''
print, 'HYADES 2D data analysis shell, v.0.2'
print, ''

run = ''

print, ''
getrun: read, run, prompt='Enter run name: '
if (run eq '') then begin
    goto, getrun
endif else begin
    filename = run+'.cdf'
    
    openr, lun, filename, /get_lun, error=err
    if (err ne 0) then begin
        printf, -2, !err_string ; write to stderr
        goto, getrun
    endif
    
    print, 'Reading data from: ', filename
    
    h2d_data = read_h2d(filename)
endelse



;;
;; Print out run information
;;
print, ''
h2d_data->printRunInfo
print, 'Dump times: '
print, h2d_data->getDumpTimes()


;; Housekeeping on the heap
heap_gc

end
