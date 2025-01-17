library(hexSticker)
library(showtext)
setwd('~/Documents/assoRted/BarnebyLives/man/figures')

font_add_google('Open Sans', regular.wt = 400) # download the font locally each session.
p <- 'BarnebyLivesPress-trans.png'

sticker(
	p,
	filename = 'logo.png',

	# hexagon colours
	h_fill = 'black',
	h_color = '#FF8427',

	# control image placement and size
	s_x = 1, s_y = 1.3, s_width = 0.75,

	# package name specs
	package = 'BarnebyLives',
	p_family = 'Exo 2',
	p_color = 'white',
	p_size = 20,
	p_y = 0.6,
	dpi = 300
)
