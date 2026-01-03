# Rendering a shipping manifest

I find it to be good practice to include both a shipping manifest and
short note to the curators who are receiving material when I ship out my
collections. The ‘short notes’ I generally send are slightly
post-card-esque, unless working on some big government type project -
which the note in the example will be. In general I just like these as a
nice little way of adding a bit of personal touch or warmth to the
interaction.

The shipping manifests are very important for practical reasons. They
allow me to check off material and make sure it is packed. They also
seem like a cool old school way of helping people figure what is meant
to be where. More feel than *another* email.

BL has a default template for this process, which automatically combines
the transmittal notice with the shipping manifest.  
As with the other templates from BL, this one is easily modifiable, and
make these changes to a local copy which you have copied out of the
packages contents. Unlike the herbarium labels, you will *need* to
manually update some values, and the file itself will be rendered to pdf
in whichever location it is found. Theoretically you can probably pass
in a few of these args from a user profile or your global settings.

Here we copy the file over to a more ‘natural’ part of the computers
file system just like we did with the label templates.

``` r
p2libs <- system.file(package = 'BarnebyLives')

folds <- file.path(
  'BarnebyLives', 'rmarkdown', 'templates', 'SoS_transmittal', 'skeleton', 'skeleton.Rmd')

file.copy(from = file.path(p2libs, folds), to =  '.')
```

Remember, changing the ‘to’ parameter in `file.copy` will allow it go
wherever you want it to. In this example we copy the file into our
working directory (‘.’).

Now you have the skeleton for the transmittal notice in your desired
directory. Open the skeleton up in a R tab, and fill out the `User`
defined settings. An example is below (do this in the template! not
here).

``` r
herbarium_code <- 'F' # index herbariorum code
project <- data.frame(
  Name = 'Seeds of Success', # the project name. 
  Project_description = 'native seed conservation and development project',
  # short description
  Organization = 'Chicago Botanic Garden',
  Phone = '312-XXX-0257',
  Person = 'Reed Benkendorf',
  Email = 'rxxkendork@chicagotbotanicxx.org',
  PersonTitle = 'Lead Botanist',
  Sets = 'quadruplicate',
  Permits = 'These materials were collected under the auspices of the US Department of Interiors Bureau of Land Management, unless noted otherwise.'
)
```

These are your contact details which will go onto the letter head, and
provide some context about the collections.

Next you will need to point towards the specimens you want to send. In
this case I use a relative path to point towards the output from the BL
cleaning pipeline. I select the few fields which matter, and create some
empty ones for me to manually check off with a pen as I am packing
material.

In the example below I include a little stringr::str_replace call to
strip away all but my first initial from my first name. It’s not super
safe, For example a first name like ‘McKenna’ would results in ‘MK’
being left behind - modify, or remove it, as desired.

``` r
herbarium <- herbaria_info |> 
  dplyr::filter(Abbreviation == herbarium_code)
specimens <- read.csv('../../results/collections-YOUR_NAME.csv') |>
  dplyr::select(Primary_Collector, Collection_number, Full_name) |> 
  dplyr::mutate(
    Packed = "", 
    Received = "", 
    Primary_Collector = stringr::str_replace(Primary_Collector, "[a-z]+", ".")) 
```

Once you have made all of your changes simply run the job. And once
you’ve done that you can ‘knit’ the document using the ‘knit’ button in
Rmarkdown’s graphic user interface or `Ctrl + Shift + k`.
