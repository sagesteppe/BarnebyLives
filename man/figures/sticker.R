library(hexSticker)
library(showtext)

font_add_google('Exo 2', regular.wt = 400) # download the font locally each session. 
p <- 'inst/man/figures/BarnebyLivesPress-blk.png'

sticker(
	p, 
	filename = 'inst/man/figures/logo.png', 
	
	# hexagon colours
	h_fill = '#8080ff',
	h_color = '#80ff80', 
	
	# control image placement and size
	s_x = 1, s_y = 1.2, s_width = 0.6, 
	
	# package name specs
	package = 'safeHavens',
	p_family = 'Exo 2',  
	p_color = 'white',
	p_size = 24, 
	p_y = 0.6,
	dpi = 300
)
