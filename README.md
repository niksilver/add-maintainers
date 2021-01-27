# Run the script

```
./fetch.pl
```

# Don't get asked for credentials every time

From [Stackoverflow](https://stackoverflow.com/questions/10032461/git-keeps-asking-me-for-my-ssh-key-passphrase):

```
eval $(ssh-agent)
ssh-add
```

Then enter the passphrase once and run the script to clone the repositories.
