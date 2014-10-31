##### Signed by https://keybase.io/clcollins
```
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEABECAAYFAlRToeUACgkQte6EFif3vzc6rwCgnNXstQMC+vwUZPN9c6LSmiwU
haIAoIiWt2wfycdoYgc8jEKYQB2hsz+v
=2kak
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size   exec  file             contents                                                        
             ./                                                                               
21             .gitignore     4c1dd07a78243001dedd898699bbcb5d43310a310fcfab298b89c33af5b9ec7c
1547           Dockerfile     c8432f53c3a069722e05a5cd7ab6304d63004c4f094f198f4dfef478b8df7a45
35121          LICENSE        e1c0ad728983d8a57335e52cf1064f1affd1d454173d8cebd3ed8b4a72b48704
2421           README.md      463fc3d01b0a87e2f927e33f18b2b3c9bd6f61beae10550be485d942b4e91081
619    x       build-rpm.sh   9e538a9bc39593c7012f6041aa94901714d06a64dfcca303ba232043d4130cab
1997   x       run-apache.sh  71072e085e6400bb90002dc6e8d36618bfd88b36b32cd2e8bbd84d3be10f000d
```

#### Ignore

```
/SIGNED.md
```

#### Presets

```
git      # ignore .git and anything as described by .gitignore files
dropbox  # ignore .dropbox-cache and other Dropbox-related files    
kb       # ignore anything as described by .kbignore files          
```

<!-- summarize version = 0.0.9 -->

### End signed statement

<hr>

#### Notes

With keybase you can sign any directory's contents, whether it's a git repo,
source code distribution, or a personal documents folder. It aims to replace the drudgery of:

  1. comparing a zipped file to a detached statement
  2. downloading a public key
  3. confirming it is in fact the author's by reviewing public statements they've made, using it

All in one simple command:

```bash
keybase dir verify
```

There are lots of options, including assertions for automating your checks.

For more info, check out https://keybase.io/docs/command_line/code_signing