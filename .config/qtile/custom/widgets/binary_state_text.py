from libqtile.widget import TextBox
from libqtile.log_utils import logger
class BinaryStateText(TextBox):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.state = False

    def button_press(self, x, y, button):
        super().button_press(x,y,button)
        logger.exception("Button pressed")
        self.state_toggle()


    def state_toggle(self):
        logger.exception("State changed")
        self.state = not self.state
