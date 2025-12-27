from . import binary_state_text
from config import qtile

class DunstNotificationCentre(binary_state_text.binary_state_text):
    def __init__(self, on_cmd, off_cmd,*args,**kwargs):
        super().__init__(*args, **kwargs)
        self.on_cmd = on_cmd
        self.off_cmd = off_cmd

    def left_click_action(self):
        if self.state:
            qtile.cmd_spawn(self.on_cmd)
        else:
            qtile.cmd_spawn(self.off_cmd)

