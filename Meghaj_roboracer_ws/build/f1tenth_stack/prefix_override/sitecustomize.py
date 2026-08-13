import sys
if sys.prefix == '/usr':
    sys.real_prefix = sys.prefix
    sys.prefix = sys.exec_prefix = '/home/orin/Desktop/roboracer-purdue/Meghaj_roboracer_ws/install/f1tenth_stack'
