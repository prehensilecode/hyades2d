;;
;;  GUI for visualizing HYADES 2D output.
;;
;;               -- David Chin, 13 July 1999
;;
;; $Id: h2d_gui.pro,v 1.1.1.1 1999/09/03 14:32:03 dwchin Exp $
;;

@read_h2d

pro H2dEventHandler, event
    
    ;; Get state structure
    widget_control, event.top, get_uvalue=state, /no_copy
    
    ;; Get value of button press
    widget_control, event.id, get_value=button_value
    
    ;; DEBUGGING
    ;;help, event, /struct
    ;;print, button_value
    
    case button_value of
        'About...': begin
            infoText = ['HYADES 2D Analysis Tool GUI, v. 0.7']
            ;;showinfo, title='HYADES 2D Analysis Tool', group=event.top,  $
            ;;width=40, height=12, infotext=infoText 
            result = dialog_message(infoText, /information,   $
                                    title='About', $
                                    dialog_parent=event.top)
        end
        
        'Rho': begin
            state.plot_var = 'rho'
        end
        
        'Te': begin
            state.plot_var = 'te'
        end
        
        'Ti': begin 
            state.plot_var = 'ti'
        end
        
        'Tr': begin
            state.plot_var = 'tr'
        end
        
        'Pres': begin
            state.plot_var = 'pres'
        end
        
        'Contour': begin
            state.contour = not(state.contour) ; toggle value
        end
        
        'Cell': begin
            state.contour = not(state.contour)
        end
        
        'Grid': begin
            state.nogrid = not(state.nogrid) ; toggle value
        end
        
        'Fill': begin
            state.nofill = not(state.nofill) ; toggle value
        end
        
        else: begin
            print, 'FOOEY!'
        end
    endcase
    
    ;; DEBUGGING
    ;;help, state, /struct
    
    widget_control, event.top, set_uvalue=state, /no_copy

end


;;=======================================================


pro H2dOpen, event
    
    ;; Get state structure
    widget_control, event.top, get_uvalue=state, /no_copy
    
    state.filename = dialog_pickfile(/read, filter='*.cdf')
    
    if state.filename ne '' then begin
        ;; clean up previous data
        obj_destroy, *state.data_obj_ptr
        ptr_free, state.data_obj_ptr
        
        ;; read in new data
        openr, lun, state.filename, /get_lun, error=err
        tmp = read_h2d(state.filename)
        state.data_obj_ptr = ptr_new(tmp, /no_copy)
        close, lun
    endif
    
    ;; Set state structure
    widget_control, event.top, set_uvalue=state, /no_copy
    
end


;;=======================================================


pro H2dExit, event
    
    ;; Event handler to exit program
    widget_control, event.top, /destroy
    
    ;;print, 'Ciao!'
    
end


;;=======================================================


pro H2dCleanup, wH2dWindow
    
    ;; DEBUGGING
    ;;print, 'Must CLEAN HOUSE! SPOOONNNN!'
    
    widget_control, wH2dWindow, get_uvalue=state, /no_copy
    obj_destroy, *state.data_obj_ptr
    ptr_free, state.data_obj_ptr
    
    help, /heap
    
end


;;==========================================================

pro H2dAnimate, event
    
    ;;
    ;; Tells data to animate: plot grid of zones by position, color in
    ;; for variable value.
    ;;
    
    ;; Get state structure
    widget_control, event.top, get_uvalue=state, /no_copy
    
    (*state.data_obj_ptr)->animate, state.plot_var,  $
      group_leader=state.tlb, nogrid=state.nogrid,  $
      contour=state.contour, nofill=state.nofill
    
    ;; Put back state structure
    widget_control, event.top, set_uvalue=state, /no_copy
    
end


;;==============================================================

pro H2dAnimZone, event
    
    ;;
    ;; Tells data to animate: interpret matrix of values as an image.
    ;;
    
    ;; Get state structure
    widget_control, event.top, get_uvalue=state, /no_copy
    
    (*state.data_obj_ptr)->animZone, state.plot_var, group_leader=state.tlb
    
    ;; Put back state structure
    widget_control, event.top, set_uvalue=state, /no_copy
    
end

;;==============================================================


pro H2D_Gui, runname=runname, _extra=extra, ncolors=ncolors
    
    ;;
    ;; Main GUI interface.
    ;;
    
    ;;if n_elements(ncolors) eq 0 then ncolors = (!d.n_colors < 256)
    
    ;; Fix color table
    if !d.n_colors gt 256 then device, decomposed=0
    loadct, 4
    
    ;; Get data from an input file.  Input file must be in netCDF
    ;; format.
    if n_elements(runname) ne 0 then begin
        filename = runname+'.cdf'
        openr, lun, filename, /get_lun, error=err
        h2d_data = read_h2d(filename)
        close, lun
    endif else begin
        filename = ''           ; no default filename
        
        while filename eq '' do begin
            filename = dialog_pickfile(/read, filter='*.cdf')
            openr, lun, filename, /get_lun, error=err
        endwhile
        
        h2d_data = read_h2d(filename)
        close, lun
    endelse
    
    ;; Make a pointer to the h2d data object; use pointer to save
    ;; memory, since this object needs to be accessible by the event
    ;; handlers.  Event handlers will send objects messages, e.g. to
    ;; perform animation.
    h2d_data_ptr = ptr_new(temporary(h2d_data))
    
    ;;
    ;; Top level base widget, non-resizable
    ;;
    wH2dWindow = widget_base(title='H2D Analysis', mbar=wMenuBar)
    
    widget_control, /managed, wH2dWindow ; manage top level widget
    
    ;;
    ;; The File menu
    ;;
    wFileMenu = widget_button(wMenuBar, value='File', /menu)
    
    ;; Open... 
    wOpenItem = widget_button(wFileMenu, value='Open...', $
                              event_pro='H2dOpen')
    
    ;; Exit...
    wExitItem = widget_button(wFileMenu, value='Exit',  $
                              event_pro='H2dExit')
    
    ;;
    ;; The Help menu
    ;;
    wHelpMenu = widget_button(wMenuBar, value='Help', /menu, /align_right)
    
    ;; About...
    wAboutItem = widget_button(wHelpMenu, value='About...')
    
    
    ;; Main panel
    wH2dBase = widget_base(wH2dWindow, /row)
    
    ;; Divide main panel into 3 panes: left, middle, and right
    wH2dLeft  = widget_base(wH2dBase, /column)
    wH2dMid   = widget_base(wH2dBase, /column)
    wH2dRight = widget_base(wH2dBase, /column)
    
    ;; Divide left pane into top and bottom
    wH2dLeftTop = widget_base(wH2dLeft, /column)
    wH2dLeftBottom = widget_base(wH2dLeft, /column, /exclusive, /frame)
    
    ;; Divide middle pane into top, and bottom
    wH2dMidTop = widget_base(wH2dMid, /column)
    wH2dMidBottom = widget_base(wH2dMid, /column, /frame)
    
    ;; Divide right pane into top, 2 middle panes, and a bottom pane
    wH2dRightTop = widget_base(wH2dRight, /column)
    wH2dRightBottom = widget_base(wH2dRight, /column, /frame)
    
    wH2dRightBotMid = widget_base(wH2dRightBottom, /row)
    wH2dRightBotBot = widget_base(wH2dRightBottom, /column)
    
    wH2dRightBotMidLeft = widget_base(wH2dRightBotMid, /column, /exclusive)
    wH2dRightBotMidRight = widget_base(wH2dRightBotMid, /column, /nonexclusive)
    
    ;;
    ;; Left pane controls selection of variables
    ;;
    
    ;; Label for left pane
    wH2dLeftLabel  = widget_label(wH2dLeftTop, value='Variables',  $
                                  /align_center)
    
    ;; Radio buttons for selecting data to display
    wH2dRhoButton  = widget_button(wH2dLeftBottom, value='Rho', $
                                   /no_release)
    wH2dTeButton   = widget_button(wH2dLeftBottom, value='Te', $
                                   /no_release)
    wH2dTiButton   = widget_button(wH2dLeftBottom, value='Ti', $
                                   /no_release)
    wH2dTrButton   = widget_button(wH2dLeftBottom, value='Tr', $
                                   /no_release)
    wH2dPresButton = widget_button(wH2dLeftBottom, value='Pres', $
                                   /no_release)

    ;; Make Te the default selection
    widget_control, wH2dTeButton, /set_button
    
    ;;
    ;; Middle pane controls Zone Plot
    ;;
    
    ;; Label for middle pane
    wH2dMidLabel = widget_label(wH2dMidTop, value='Zone Plot', /align_center)
    
    ;; Zone anim button
    wH2dZoneButton = widget_button(wH2dMidBottom,  $
                                   value='GO', $
                                   event_pro='H2dAnimZone', $
                                   /align_center)
    
    ;;
    ;; Right pane controls Position Plot
    ;;
    
    ;; Label for right pane
    wH2dRightLabel = widget_label(wH2dRightTop, value='Position Plot',  $
                                  /align_center)
    
    ;; Buttons to select between cell and contour plots
    wH2dCellButton = widget_button(wH2dRightBotMidLeft, value='Cell', $
                                   /no_release)
    wH2dContourButton = widget_button(wH2dRightBotMidLeft, value='Contour', $
                                      /no_release)
    
    ;; Buttons for options
    wH2dGridButton = widget_button(wH2dRightBotMidRight, value='Grid')
    wH2dFillButton = widget_button(wH2dRightBotMidRight, value='Fill')
    
    ;; Action button
    wH2dPosButton = widget_button(wH2dRightBotBot, value='GO',  $
                                  event_pro='H2dAnimate', $
                                  /align_center)
    
    widget_control, wH2dCellButton, /set_button
    widget_control, wH2dGridButton, /set_button
    widget_control, wH2dFillButton, /set_button
    
    ;; Realize the GUI
    widget_control, wH2dWindow, /realize
    
    
    ;; Create the "state" structure
    state = {h2d_state_struct, $
             tlb: wH2dWindow, $
             filename: filename, $
             plot_var: 'te', $  ; name of variable to be plotted (default)
             nogrid: 0, $       ; don't put grid on irrtv animation
             contour: 0, $      ; use contour plot
             nofill: 0, $       ; don't fill contour plot
             data_obj_ptr: h2d_data_ptr}
    
    ;; Store info structure in a memory location outside any program
    ;; module.  Use the user value of the top level base widget
    ;; wH2dBase.
    widget_control, wH2dWindow, set_uvalue=state, /no_copy
    
    ;; DEBUGGING
    ;;help, state, /struct
    
    ;; Manage the GUI
    xmanager, 'H2D_Gui', wH2dWindow, $
      event_handler='H2dEventHandler', $
      cleanup='H2dCleanup', /no_block
    
end
