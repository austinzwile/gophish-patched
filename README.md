![gophish logo](https://raw.github.com/gophish/gophish/master/static/images/gophish_purple.png)

Gophish
=======

Gophish: Open-Source Phishing Toolkit

[Gophish](https://getgophish.com) is an open-source phishing toolkit designed for businesses and penetration testers. It provides the ability to quickly and easily setup and execute phishing engagements and security awareness training.

Patched Gophish
===============

This repo is a patched variant of gophish that is specifically tailored to running Office 365 product simulations. This variant of gophish has removed all indicators of compromise (that I could find) and has a very nice install script that automatically configures TLS through Lets Encrypt and then sets up gophish as a service and enables it by default. 

### Install

Simply run the `gophish_install.sh` file as root (you don't even really need the full repo, you can just download the script from here: [gophish_install.sh](https://raw.githubusercontent.com/austinzwile/gophish-patched/refs/heads/master/gophish_install.sh) and then all you have to do is:

```bash
chmod +x ./gophish_install.sh
sudo ./gophish_install.sh "example.com" "youremail@whatever.com"
```

And it will automatically take care of the everything for you.

Enjoy!

### Documentation

Documentation can be found on [site](http://getgophish.com/documentation). Find something missing? Let the gophish team (or me) know by filing an issue!

### Issues

Find a bug? Want more features? Find something missing in the documentation? Let us know! Please don't hesitate to [file an issue](https://github.com/austinzwile/gophish-patched/issues/new) and I'll get right on it.

### Credits

Mad respect to the creators of Gophish, I did not create this project but it has been critical in the execution of hundreds of my social engineering engagements over the years. But if you like the very minor changes I've made to the product, feel free to go star the project along with the original [here](https://github.com/gophish/gophish).

### License
```
Gophish - Open-Source Phishing Framework

The MIT License (MIT)

Copyright (c) 2013 - 2020 Jordan Wright

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software ("Gophish Community Edition") and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
