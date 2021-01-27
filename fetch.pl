#!/usr/bin/perl

use strict;
use warnings;

# open OUTPUT, '>repos.csv' or die "Could not open repos array\n";

# Test - format is user/repo,team
#
# process(q{
# niksilver/testgh1,Nik
# niksilver/testgh2,Nik
# });

process(q{
});

# process(q{
# });

# Archived:
# ably/admin_api,Website

# close OUTPUT;

sub process {
    my $repos = $_[0];

    open REPOS, '<', \$repos or die "Could not open repos array\n";
    while (<REPOS>) {

        chomp;
        my $repo_owner = $_;
        my ($repo, $owner) = split /,/, $repo_owner;
        if ($repo eq "") {
            next;
        }

        print "--------------- Repo:  $repo\n";
        print "--------------- Owner: $owner\n";

        # Clone repo ably/something into directory ably/something
        my $result = system("gh repo clone $repo $repo");

        # # Get the last few committers
        # @authors = committers($repo);
        #
        # # Print the results to our output file
        # print OUTPUT "$repo," . (join ",", @authors) . "\n";

        # Add the right maintainers file, commit, push, make pull request
        commit_maintainers($repo, $owner);
    }
    close REPOS;
}

sub committers {
    my $repo = $_[0];

    my @authors = ();

    # Get the last few log entries
    my $log = qx(cd $repo ; git log);

    print "\n\n\-------------- Log:\n$log-------------\n";

    # Get the authors of these
    open LINES, '<', \$log or die "Could not read log lines\n";
    while (<LINES>) {

        chomp;
        my $line = $_;
        if ($line =~ /Author: /) {
            $line =~ s/^Author: //;
            $line =~ s/ <.*//;
            print "    Author: $line\n";
            push @authors, $line;
        }
    }
    close LINES;

    # Limit it to four authors
    @authors = @authors[0..3];

    return @authors;
}

sub commit_maintainers {
    my ($repo, $owner) = @_;

    my $maint_filename = "MAINTAINERS.md";
    my $branch = "adding-maintainer";
    chdir $repo;

    nice_exec("git checkout -b $branch", "New git branch failed");

    open(MAINT, '>', "$maint_filename") or die "Could not open maintainers file\n";
    print MAINT "This repository is owned by the Ably $owner team.\n";
    close MAINT;

    nice_exec("git add $maint_filename", "git add failed");
    nice_exec("git commit $maint_filename -m 'Clarified ownership'", "git commit failed");
    nice_exec("git push --set-upstream origin $branch", "git push failed");
    nice_exec("gh pr create --title 'Add maintainers file'  --body 'Add maintainers file'", "Creating pull request failed");
}

sub nice_exec {
    my ($cmd, $msg) = @_;

    print "cmd: $cmd\n";
    print qx($cmd);
    $? == 0 or die "$msg: $!\n";
}
