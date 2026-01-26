# Generate CSS Classes for icons
All icons in svg will have names. What this python script does is, it uses those name to generate css classes. So that you can directly use those classes in html elements and the icons will be appended.

[Python script](./classgen.py)
* I've used `TODO` comment in places where you can change according to your need. search TODO and look for the highlighted variable name.
* Add prefix(`.Movie-`) to get unique classes for the fonts and suffix (:before) inside `prefix` and `suffix` variable.
* The output file location can be change inside `new_file` variable.
* If you already have a css file for this, you can add the location of the file inside `source_file`.