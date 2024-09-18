%% This script defines the twiddle factors for each of the DFT stages.

%% DFT7
DFT7_TWID0 = int16([
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(0,0);
complex(32767,0);
complex(20431,-25619);
complex(-7292,-31946);
complex(-29523,-14218);
complex(-29523,14218);
complex(-7292,31946);
complex(20431,25619);
complex(0,0);
complex(32767,0);
complex(-7292,-31946);
complex(-29523,14218);
complex(20431,25619);
complex(20431,-25619);
complex(-29523,-14218);
complex(-7292,31946);
complex(0,0);
complex(32767,0);
complex(-29523,-14218);
complex(20431,25619);
complex(-7292,-31946);
complex(-7292,31946);
complex(20431,-25619);
complex(-29523,14218);
complex(0,0) ]);

DFT7_TWID1 = int16([
complex(32767,0);
complex(-29523,14218);
complex(20431,-25619);
complex(-7292,31946);
complex(-7292,-31946);
complex(20431,25619);
complex(-29523,-14218);
complex(0,0);
complex(32767,0);
complex(-7292,31946);
complex(-29523,-14218);
complex(20431,-25619);
complex(20431,25619);
complex(-29523,14218);
complex(-7292,-31946);
complex(0,0);
complex(32767,0);
complex(20431,25619);
complex(-7292,31946);
complex(-29523,14218);
complex(-29523,-14218);
complex(-7292,-31946);
complex(20431,-25619);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0)]);

%% DFT9
DFT9_TWID0 = int16([
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(25102,-21063);
complex(5690,-32270);
complex(-16384,-28378);
complex(-30792,-11207);
complex(-30792,11207);
complex(-16384,28378);
complex(5690,32270);
complex(32767,0);
complex(5690,-32270);
complex(-30792,-11207);
complex(-16384,28378);
complex(25102,21063);
complex(25102,-21063);
complex(-16384,-28378);
complex(-30792,11207);
complex(32767,0);
complex(-16384,-28378);
complex(-16384,28378);
complex(32767,0);
complex(-16384,-28378);
complex(-16384,28378);
complex(32767,0);
complex(-16384,-28378);
complex(32767,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(25102,21063);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(5690,32270);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(-16384,28378);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0)]);

DFT9_TWID1 = int16([
complex(32767,0);
complex(-30792,-11207);
complex(25102,21063);
complex(-16384,-28378);
complex(5690,32270);
complex(5690,-32270);
complex(-16384,28378);
complex(25102,-21063);
complex(32767,0);
complex(-30792,11207);
complex(25102,-21063);
complex(-16384,28378);
complex(5690,-32270);
complex(5690,32270);
complex(-16384,-28378);
complex(25102,21063);
complex(32767,0);
complex(-16384,28378);
complex(-16384,-28378);
complex(32767,0);
complex(-16384,28378);
complex(-16384,-28378);
complex(32767,0);
complex(-16384,28378);
complex(32767,0);
complex(5690,32270);
complex(-30792,11207);
complex(-16384,-28378);
complex(25102,-21063);
complex(25102,21063);
complex(-16384,28378);
complex(-30792,-11207);
complex(-30792,11207);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(-30792,-11207);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(-16384,-28378);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(5690,-32270);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0)]);

DFT9_TWID2 = int16([
complex(32767,0);
complex(25102,21063);
complex(5690,32270);
complex(-16384,28378);
complex(-30792,11207);
complex(-30792,-11207);
complex(-16384,-28378);
complex(5690,-32270);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(25102,-21063);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0);
complex(0,0)]);

%% DFT16
DFT16_TWID = int16([
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(30274,-12540);
complex(23170,-23170);
complex(12540,-30274);
complex(0,-32768);
complex(-12540,-30274);
complex(-23170,-23170);
complex(-30274,-12540);
complex(32767,0);
complex(23170,-23170);
complex(0,-32768);
complex(-23170,-23170);
complex(-32768,0);
complex(-23170,23170);
complex(0,32767);
complex(23170,23170);
complex(32767,0);
complex(12540,-30274);
complex(-23170,-23170);
complex(-30274,12540);
complex(0,32767);
complex(30274,12540);
complex(23170,-23170);
complex(-12540,-30274);
complex(32767,0);
complex(0,-32768);
complex(-32768,0);
complex(0,32767);
complex(32767,0);
complex(0,-32768);
complex(-32768,0);
complex(0,32767);
complex(32767,0);
complex(-12540,-30274);
complex(-23170,23170);
complex(30274,12540);
complex(0,-32768);
complex(-30274,12540);
complex(23170,23170);
complex(12540,-30274);
complex(32767,0);
complex(-23170,-23170);
complex(0,32767);
complex(23170,-23170);
complex(-32768,0);
complex(23170,23170);
complex(0,-32768);
complex(-23170,23170);
complex(32767,0);
complex(-30274,-12540);
complex(23170,23170);
complex(-12540,-30274);
complex(0,32767);
complex(12540,-30274);
complex(-23170,23170);
complex(30274,-12540);
complex(32767,0);
complex(-32768,0);
complex(32767,0);
complex(-32768,0);
complex(32767,0);
complex(-32768,0);
complex(32767,0);
complex(-32768,0);
complex(32767,0);
complex(-30274,12540);
complex(23170,-23170);
complex(-12540,30274);
complex(0,-32768);
complex(12540,30274);
complex(-23170,-23170);
complex(30274,12540);
complex(32767,0);
complex(-23170,23170);
complex(0,-32768);
complex(23170,23170);
complex(-32768,0);
complex(23170,-23170);
complex(0,32767);
complex(-23170,-23170);
complex(32767,0);
complex(-12540,30274);
complex(-23170,-23170);
complex(30274,-12540);
complex(0,32767);
complex(-30274,-12540);
complex(23170,-23170);
complex(12540,30274);
complex(32767,0);
complex(0,32767);
complex(-32768,0);
complex(0,-32768);
complex(32767,0);
complex(0,32767);
complex(-32768,0);
complex(0,-32768);
complex(32767,0);
complex(12540,30274);
complex(-23170,23170);
complex(-30274,-12540);
complex(0,-32768);
complex(30274,-12540);
complex(23170,23170);
complex(-12540,30274);
complex(32767,0);
complex(23170,23170);
complex(0,32767);
complex(-23170,23170);
complex(-32768,0);
complex(-23170,-23170);
complex(0,-32768);
complex(23170,-23170);
complex(32767,0);
complex(30274,12540);
complex(23170,23170);
complex(12540,30274);
complex(0,32767);
complex(-12540,30274);
complex(-23170,23170);
complex(-30274,12540);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(32767,0);
complex(-32768,0);
complex(-30274,12540);
complex(-23170,23170);
complex(-12540,30274);
complex(0,32767);
complex(12540,30274);
complex(23170,23170);
complex(30274,12540);
complex(32767,0);
complex(23170,-23170);
complex(0,-32768);
complex(-23170,-23170);
complex(-32768,0);
complex(-23170,23170);
complex(0,32767);
complex(23170,23170);
complex(-32768,0);
complex(-12540,30274);
complex(23170,23170);
complex(30274,-12540);
complex(0,-32768);
complex(-30274,-12540);
complex(-23170,23170);
complex(12540,30274);
complex(32767,0);
complex(0,-32768);
complex(-32768,0);
complex(0,32767);
complex(32767,0);
complex(0,-32768);
complex(-32768,0);
complex(0,32767);
complex(-32768,0);
complex(12540,30274);
complex(23170,-23170);
complex(-30274,-12540);
complex(0,32767);
complex(30274,-12540);
complex(-23170,-23170);
complex(-12540,30274);
complex(32767,0);
complex(-23170,-23170);
complex(0,32767);
complex(23170,-23170);
complex(-32768,0);
complex(23170,23170);
complex(0,-32768);
complex(-23170,23170);
complex(-32768,0);
complex(30274,12540);
complex(-23170,-23170);
complex(12540,30274);
complex(0,-32768);
complex(-12540,30274);
complex(23170,-23170);
complex(-30274,12540);
complex(32767,0);
complex(-32768,0);
complex(32767,0);
complex(-32768,0);
complex(32767,0);
complex(-32768,0);
complex(32767,0);
complex(-32768,0);
complex(-32768,0);
complex(30274,-12540);
complex(-23170,23170);
complex(12540,-30274);
complex(0,32767);
complex(-12540,-30274);
complex(23170,23170);
complex(-30274,-12540);
complex(32767,0);
complex(-23170,23170);
complex(0,-32768);
complex(23170,23170);
complex(-32768,0);
complex(23170,-23170);
complex(0,32767);
complex(-23170,-23170);
complex(-32768,0);
complex(12540,-30274);
complex(23170,23170);
complex(-30274,12540);
complex(0,-32768);
complex(30274,12540);
complex(-23170,23170);
complex(-12540,-30274);
complex(32767,0);
complex(0,32767);
complex(-32768,0);
complex(0,-32768);
complex(32767,0);
complex(0,32767);
complex(-32768,0);
complex(0,-32768);
complex(-32768,0);
complex(-12540,-30274);
complex(23170,-23170);
complex(30274,12540);
complex(0,32767);
complex(-30274,12540);
complex(-23170,-23170);
complex(12540,-30274);
complex(32767,0);
complex(23170,23170);
complex(0,32767);
complex(-23170,23170);
complex(-32768,0);
complex(-23170,-23170);
complex(0,-32768);
complex(23170,-23170);
complex(-32768,0);
complex(-30274,-12540);
complex(-23170,-23170);
complex(-12540,-30274);
complex(0,-32768);
complex(12540,-30274);
complex(23170,-23170);
complex(30274,-12540)]);
