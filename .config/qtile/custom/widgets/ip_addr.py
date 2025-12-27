from libqtile.widget import base
from subprocess import Popen, PIPE
import re

ip_regex = re.compile(r"(([12]?[0-9]{1,2}\.){3}([12]?[0-9]{2})\/[0-9]{1,3})")

def get_ip(interface_name):
    p1 = Popen(["ip", "addr"], stdout=PIPE)
    p2 = Popen(["grep", interface_name], stdin=p1.stdout, stdout=PIPE)
    response = p2.stdout.read().decode("utf-8")
    p1.stdout.close()
    p2.stdout.close()
    
    ret_val = re.findall(ip_regex, response)
    return "N/A" if not len(ret_val) else ret_val[0][0].split("/")[0]

    
    
class IpAddr(base.InLoopPollText):

    orientations = base.ORIENTATION_HORIZONTAL
    defaults = [
            ("interface", "wlan0", "the interface to monitor"),
            ("update_interval", 5, "The upate interval"),
            ("disconnected_message","Disconnected", "Disconnected Message"),
            (
                "format",
                "{ip}",
                'descriptions TBA'
                )
            ]

    def __init__(self, **config):
        base.InLoopPollText.__init__(self, **config) 
        self.add_defaults(IpAddr.defaults)

    def poll(self):
        ip_addr = get_ip(self.interface)
        return self.format.format(ip = ip_addr)
