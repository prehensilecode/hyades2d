


PRO PD_EXAMPLE

desc = [ '1\Colors' , $

         '0\Red' , $

         '0\Green' , $

         '1\Blue' , $

         '0\Light' , $

         '0\Medium' , $

         '0\Dark' , $

         '0\Navy' , $

         '2\Royal' , $

         '0\Cyan' , $

         '2\Magenta' , $

         '2\Quit' ]

;Create the widget:


base = WIDGET_BASE()

menu = CW_PDMENU(base, desc, /RETURN_FULL_NAME)

WIDGET_CONTROL, /REALIZE, base

;Provide a simple event handler:


REPEAT BEGIN

    ev = WIDGET_EVENT(base)

    PRINT, ev.value

END UNTIL ev.value EQ 'Quit'

WIDGET_CONTROL, /DESTROY, base

END
