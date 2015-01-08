##### Signed by https://keybase.io/clcollins
```
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEABECAAYFAlSu9JEACgkQte6EFif3vzcj1gCg1Wh5ITE+v9T0qHJ6Lbl4Kfq9
4R0An3kEKMsc1c6E686Mtw+t4Hccczyh
=H9qq
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size   exec  file             contents                                                        
             ./                                                                               
21             .gitignore     4c1dd07a78243001dedd898699bbcb5d43310a310fcfab298b89c33af5b9ec7c
2767           Dockerfile     9d3cc072b3e09142d0acbd3fed37a0c4bdb581a96296c9e8eaf97fa7e56f2b21
35121          LICENSE        e1c0ad728983d8a57335e52cf1064f1affd1d454173d8cebd3ed8b4a72b48704
2126           README.md      09c8816f6ef18959f2418e8af4800110e05b862cc33ac8bb5ea948d989bd636e
611    x       build-rpm.sh   837481bdf0a77f9a3dc4a98055d4ab45a5de106632e0e2eeedb05ba3d8c10e57
1674   x       pre-config.sh  7d1cd63d601cc1e81186c2ef02cead8ab6655d6bd2e97552c26cee0589f5cced
606            vhost.conf     4a0b43a6ee8025dedf76ea05f30ce850f9b1a7bb8c77fead4b68ac9f279a0b49
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