package Win32::Shortcut;
#######################################################################
#
# Win32::Shortcut - Perl Module for Shell Link Interface
# ^^^^^^^^^^^^^^^
# This module creates an object oriented interface to the Win32
# Shell Links (IShellLink interface).
#
#######################################################################

$VERSION = "0.07";

require Exporter;
require DynaLoader;

@ISA= qw( Exporter DynaLoader );
@EXPORT = qw(
    SW_SHOWMAXIMIZED
    SW_SHOWMINNOACTIVE
    SW_SHOWNORMAL
);


#######################################################################
# This AUTOLOAD is used to 'autoload' constants from the constant()
# XS function.  If a constant is not found then control is passed
# to the AUTOLOAD in AutoLoader.
#

sub AUTOLOAD {
    my($constname);
    ($constname = $AUTOLOAD) =~ s/.*:://;
    #reset $! to zero to reset any current errors.
    local $!;
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($!) {
        my(undef, $file, $line) = caller;
        die "Win32::Shortcut::$constname is not defined, used at $file line $line.";
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}


#######################################################################
# PUBLIC METHODS
#

#========
sub new {
#========
    my($class, $file) = @_;
    my($ilink, $ifile) = _Instance();
    return unless $ilink && $ifile;

    my $self = bless {
        ilink            => $ilink,
        ifile            => $ifile,
        File             => "",
        Path             => "",
        Arguments        => "",
        WorkingDirectory => "",
        Description      => "",
        ShowCmd          => 0,
        Hotkey           => 0,
        IconLocation     => "",
        IconNumber       => 0,
    };


    if ($file) {
	$self->{File} = $file;
	$self->Load($file);
    }

    return $self;
}

#=========
sub Load {
#=========
    my($self, $file) = @_;
    return undef unless ref($self);
  
    my $result = _Load($self->{'ilink'}, $self->{'ifile'}, $file);

    if ($result) {
  
        # fill the properties of $self
        $self->{'File'} = $file;
        $self->{'Path'} = _GetPath($self->{'ilink'}, $self->{'ifile'},0);
        $self->{'ShortPath'} = _GetPath($self->{'ilink'}, $self->{'ifile'},1);
        $self->{'Arguments'} = _GetArguments($self->{'ilink'}, $self->{'ifile'});
        $self->{'WorkingDirectory'} = _GetWorkingDirectory($self->{'ilink'}, $self->{'ifile'});
        $self->{'Description'} = _GetDescription($self->{'ilink'}, $self->{'ifile'});
        $self->{'ShowCmd'} = _GetShowCmd($self->{'ilink'}, $self->{'ifile'});
        $self->{'Hotkey'} = _GetHotkey($self->{'ilink'}, $self->{'ifile'});
        ($self->{'IconLocation'},
         $self->{'IconNumber'}) = _GetIconLocation($self->{'ilink'}, $self->{'ifile'});
    }
    return $result;
}


#========
sub Set {
#========
    my($self, $path, $arguments, $dir, $description, $show, $hotkey, 
       $iconlocation, $iconnumber) = @_;
    return undef unless ref($self);

    $self->{'Path'}             = $path;
    $self->{'Arguments'}        = $arguments;
    $self->{'WorkingDirectory'} = $dir;
    $self->{'Description'}      = $description;
    $self->{'ShowCmd'}          = $show;
    $self->{'Hotkey'}           = $hotkey;
    $self->{'IconLocation'}     = $iconlocation;
    $self->{'IconNumber'}       = $iconnumber;
    return 1;
}


#=========
sub Save {
#=========
    my($self, $file) = @_;
    return unless ref($self);

    $file = $self->{'File'} unless $file;
    return unless $file;

    require Win32 unless defined &Win32::GetFullPathName;
    $file = Win32::GetFullPathName($file);

    _SetPath($self->{'ilink'}, $self->{'ifile'}, $self->{'Path'});
    _SetArguments($self->{'ilink'}, $self->{'ifile'}, $self->{'Arguments'});
    _SetWorkingDirectory($self->{'ilink'}, $self->{'ifile'}, $self->{'WorkingDirectory'});
    _SetDescription($self->{'ilink'}, $self->{'ifile'}, $self->{'Description'});
    _SetShowCmd($self->{'ilink'}, $self->{'ifile'}, $self->{'ShowCmd'});
    _SetHotkey($self->{'ilink'}, $self->{'ifile'}, $self->{'Hotkey'});
    _SetIconLocation($self->{'ilink'}, $self->{'ifile'},
                     $self->{'IconLocation'}, $self->{'IconNumber'});

    my $result = _Save($self->{'ilink'}, $self->{'ifile'}, $file);
    if ($result) {
	$self->{'File'} = $file unless $self->{'File'};
    }
    return $result;
}

#============
sub Resolve {
#============
    my($self, $flags) = @_;
    return undef unless ref($self);
    $flags = 1 unless defined($flags);
    my $result = _Resolve($self->{'ilink'}, $self->{'ifile'}, $flags);
    return $result;
}


#==========
sub Close {
#==========
    my($self) = @_;
    return undef unless ref($self);

    my $result = _Release($self->{'ilink'}, $self->{'ifile'});
    $self->{'released'} = 1;
    return $result;
}

#=========
sub Path {
#=========
    my($self, $value) = @_;
    return undef unless ref($self);

    if(not defined($value)) {
        return $self->{'Path'};
    } else {
        $self->{'Path'} = $value;
    }
    return $self->{'Path'};
}

#==============
sub ShortPath {
#==============
    my($self) = @_;
    return undef unless ref($self);
    return $self->{'ShortPath'};
}

#==============
sub Arguments {
#==============
    my($self, $value) = @_;
    return undef unless ref($self);

    if(not defined($value)) {
        return $self->{'Arguments'};
    } else {
        $self->{'Arguments'} = $value;
    }
    return $self->{'Arguments'};
}

#=====================
sub WorkingDirectory {
#=====================
    my($self, $value) = @_;
    return undef unless ref($self);

    if(not defined($value)) {
        return $self->{'WorkingDirectory'};
    } else {
        $self->{'WorkingDirectory'} = $value;
    }
    return $self->{'WorkingDirectory'};
}


#================
sub Description {
#================
    my($self, $value) = @_;
    return undef unless ref($self);

    if(not defined($value)) {
        return $self->{'Description'};
    } else {
        $self->{'Description'} = $value;
    }
    return $self->{'Description'};
}

#============
sub ShowCmd {
#============
    my($self, $value) = @_;
    return undef unless ref($self);

    if(not defined($value)) {
        return $self->{'ShowCmd'};
    } else {
        $self->{'ShowCmd'} = $value;
    }
    return $self->{'ShowCmd'};
}

#===========
sub Hotkey {
#===========
    my($self, $value) = @_;
    return undef unless ref($self);

    if(not defined($value)) {
        return $self->{'Hotkey'};
    } else {
        $self->{'Hotkey'} = $value;
    }
    return $self->{'Hotkey'};
}

#=================
sub IconLocation {
#=================
    my($self, $value) = @_;
    return undef unless ref($self);

    if(not defined($value)) {
        return $self->{'IconLocation'};
    } else {
        $self->{'IconLocation'} = $value;
    }
    return $self->{'IconLocation'};
}

#===============
sub IconNumber {
#===============
    my($self, $value) = @_;
    return undef unless ref($self);

    if(not defined($value)) {
        return $self->{'IconNumber'};
    } else {
        $self->{'IconNumber'} = $value;
    }
    return $self->{'IconNumber'};
}

#============
sub Version {
#============
    # [dada] to get rid of the "used only once" warning...
    return $VERSION;
}


#######################################################################
# PRIVATE METHODS
#

#============
sub DESTROY {
#============
    my($self) = @_;

    if (not $self->{'released'}) {
        _Release($self->{'ilink'}, $self->{'ifile'});
	$self->{'released'} = 1;
    }
}

bootstrap Win32::Shortcut;

1;

__END__

=head1 NAME

Win32::Shortcut - Perl Module to deal with Windows Shortcuts

=head1 SYNOPSIS

This module implements the Win32 IShellLink Interface to allow
management of shortcut files from Perl.

  use Win32::Shortcut;

  $LINK = Win32::Shortcut->new();
  $LINK->{'Path'} = "C:\\Directory\\Target.exe";
  $LINK->{'Description'} = "Target executable";
  $LINK->Save("Target.lnk");
  $LINK->Close();

=head1 REFERENCE

=head2 General Usage

To use this module, first add the following line at the beginning of
your script:

  use Win32::Shortcut;

Then, use this command to create a shortcut object:

  $LINK = Win32::Shortcut->new();

This function will create a C<$LINK> object on which you can apply the
Methods and Properties explained later.

The object is not yet a shortcut file; it is just the definition of a
shortcut. Basically, you can do 2 things:

=over

=item 1. Load a shortcut file into the object.

=item 2. Save the object into a shortcut file.

=back

For the rest, the object can be accessed as it were a normal
associative array reference. It has the following keys (here referred
as properties):

  $LINK->{'File'}
  $LINK->{'Path'}               $LINK->Path()
  $LINK->{'ShortPath'}
  $LINK->{'WorkingDirectory'}   $LINK->WorkingDirectory()
  $LINK->{'Arguments'}          $LINK->Arguments()
  $LINK->{'Description'}        $LINK->Description()
  $LINK->{'ShowCmd'}            $LINK->ShowCmd()
  $LINK->{'Hotkey'}             $LINK->Hotkey()
  $LINK->{'IconLocation'}       $LINK->IconLocation()
  $LINK->{'IconNumber'}         $LINK->IconNumber()

Thus, assuming you have a shortcut file named C<test.lnk> in your
current directory, this simple script will tell you where this shortcut
points to:

  use Win32::Shortcut;
  $LINK = Win32::Shortcut->new();
  $LINK->Load("test.lnk");
  print "Shortcut to: $LINK->{'Path'} $LINK->{'Arguments'} \n";
  $LINK->Close();

But you can also modify its values:

  use Win32::Shortcut;
  $LINK = Win32::Shortcut->new();
  $LINK->Load("test.lnk");
  $LINK->{'Path'} =~ s/C:/D:/i;   # move the target from C: to D:
  $LINK->{'ShowCmd'} = SW_NORMAL; # runs in a normal window

and then you can save your changes to the shortcut file with this
command:

  $LINK->Save();
  $LINK->Close();

or you can save it with another name, creating a new shortcut file:

  $LINK->Save("test2.lnk");
  $LINK->Close();

Finally, you can create a completely new shortcut:

  $LINK = Win32::Shortcut->new();
  $LINK->{'Path'} = "C:\\PERL5\\BIN\\PERL.EXE";
  $LINK->{'Arguments'} = "-v";
  $LINK->{'WorkingDirectory'} = "C:\PERL5\\BIN";
  $LINK->{'Description'} = "Prints out the version of Perl";
  $LINK->{'ShowCmd'} = SW_SHOWMAXIMIZED;
  $LINK->Save("Perl Version Info.lnk");
  $LINK->Close();

Note also that in the examples above the two lines:

  $LINK = Win32::Shortcut->new();
  $LINK->Load("test.lnk");

can be collapsed to:

  $LINK = Win32::Shortcut->new("test.lnk");


=head2 Methods

=over

=item B<Close>

Closes a shortcut object. Note that it is not "strictly" required to
close the objects you created, since the Win32::Shortcut objects are
automatically closed when the program ends (or when you elsehow destroy
such an object).

Note also that a shortcut is not automatically saved when it is closed,
even if you modified it. You have to call Save in order to apply
modifications to a shortcut file.

Example:

  $LINK->Close();

=item B<Load> I<file>

Loads the content of the shortcut file named I<file> in a shortcut
object and fill the properties of the object with its values. Will
return B<undef> on errors, or a true value if everything was
successful.

Example:

  $LINK->Load("test.lnk") or print "test.lnk not found!";

  print join("\n", $LINK->Path,
                   $LINK->ShortPath,
                   $LINK->Arguments,
                   $LINK->WorkingDirectory,
                   $LINK->Description,
                   $LINK->ShowCmd,
                   $LINK->Hotkey,
                   $LINK->IconLocation,
                   $LINK->IconNumber);
  }

=item B<new Win32::Shortcut> I<[file]>

Creates a new shortcut object. If a filename is passed in I<file>,
automatically Loads this file also. Returns the object created or
B<undef> on errors.

Example:

  $LINK = Win32::Shortcut->new();

  $RegEdit = Win32::Shortcut->new("Registry Editor.lnk");
  die "File not found" if not $RegEdit;

=item B<Resolve> I<[flag]>

Attempts to automatically resolve a shortcut and returns the resolved
path, or B<undef> on errors; in case no resolution was made, the path
is returned unchanged. Note that the path is automatically updated in
the Path property of the shortcut.

By default this method acts quietly, but if you pass a value of 0
(zero) in the I<flag> parameter, it will eventually post a dialog box
prompting the user for more information.

Example:

  # if the target doesn't exist...
  if(! -f $LINK->Path) {
    # save the actual target for comparison
    $oldpath = $LINK->Path;

    # try to resolve it (with dialog box)
    $newpath = $LINK->Resolve(0);

    die "Not resolved..." if $newpath == $oldpath;
  }

=item B<Save> I<[file]>

Saves the content of the shortcut object into the file named I<file>.
If I<file> is omitted, it is taken from the File property of the object
(which, if not changed, is the name of the last Loaded file).

If no file was loaded and the File property doesn't contain a valid
filename, the method will return B<undef>, which will also be returned
on errors. A true value will be returned if everything was successful.

Example:

 $LINK->Save();
 $LINK->Save("Copy of " . $LINK->{'File'});

=item B<Set> I<path, arguments, workingdirectory, description, showcmd,
hotkey, iconlocation, iconnumber>

Sets all the properties of the shortcut object with a single command.
This method is supplied for convenience only, you can also set those
values changing the values of the properties.

Example:

  $LINK->Set("C:\\PERL5\\BIN\\PERL.EXE",
             "-v",
             "C:\\PERL5\\BIN",
             "Prints out the version of Perl",
             SW_SHOWMAXIMIZED,
             hex('0x0337'),
             "C:\\WINDOWS\\SYSTEM\\COOL.DLL",
             1);

  # it is the same of...
  $LINK->Path("C:\\PERL5\\BIN\\PERL.EXE");
  $LINK->Arguments("-v");
  $LINK->WorkingDirectory("C:\\PERL5\\BIN");
  $LINK->Description("Prints out the version of Perl");
  $LINK->ShowCmd(SW_SHOWMAXIMIZED);
  $LINK->Hotkey(hex('0x0337'));
  $LINK->IconLocation("C:\\WINDOWS\\SYSTEM\\COOL.DLL");
  $LINK->IconNumber(1);

=back

=head2 Properties

The properties of a shortcut object can be accessed as:

  $OBJECT->{'property'}

Eg., assuming that you have created a shortcut object with:

  $LINK=new Win32::Shortcut();

you can for example see its description with:

  print $LINK->{'Description'};

You can of course also set it:

  $LINK->{'Description'}="This is a description";

From version 0.02, those properties have also a corresponding method
(subroutine), so you can write the 2 lines above using this syntax too:

  print $LINK->Description;
  $LINK->Description("This is a description");

The properties of a shortcut reflect the content of the Shortcut
Properties Dialog Box, which can be obtained by clicking the third
mouse button on a shortcut file in the Windows 95 (or NT 4.0) Explorer
and choosing "Properties" (well, I hope you already knew :).

The fields corresponding to the single properties are marked in B<bold>
in the following list.

=over

=item B<Arguments>

The arguments associated with the shell link object. They will be
passed to the targeted program (see Path) when it gets executed. In
fact, joined with Path, this parameter forms the "B<Target>" field of a
Shortcut Properties Dialog Box.

=item B<Description>

An optional description given to the shortcut. Seems to be missing in
the Shortcut Properties Dialog Box (not yet implemented?).

=item B<File>

The filename of the shortcut file opened with Load, and/or the filename
under which the shortcut will be saved with Save (if the I<file>
argument is not specified).

=item B<Hotkey>

The hotkey associated to the shortcut, in the form of a 2-byte number
of which the first byte identifies the modifiers (Ctrl, Alt, Shift...
but I didn't find out how it works) and the second is the ASCII code of
the character key. Correspond to the "B<Shortcut key>" field of a
Shortcut Properties Dialog Box.

=item B<IconLocation>

The file that contain the icon for the shortcut. Seems actually to
always return nothing (YMMV, I hope...).

=item B<IconNumber>

The number of the icon for the shortcut in the file pointed by
IconLocation, in case more that one icon is contained in that file (I
suppose this, documentation isn't so clear at this point).

=item B<Path>

The target of the shortcut. This is (joined with Arguments) the content
of the "B<Target>" field in a Shortcut Properties Dialog Box.

=item B<ShortPath>

Same as Path, but expressed in a DOS-readable format (8.3 characters
filenames). It is available as read-only (well, you can change it, but
it has no effect on the shortcut; change Path instead) once you Load a
shortcut file.

=item B<ShowCmd>

The condition of the window in which the program will be executed (can
be Normal, Minimized or Maximized). Correspond to the "B<Run>" field of
a Shortcut Properties Dialog Box.

Allowed values are:

B<Value>    B<Meaning>       B<Constant>

   1     Normal Window SW_SHOWNORMAL
   3     Maximized     SW_SHOWMAXIMIZED
   7     Minimized     SW_SHOWMINNOACTIVE

Any other value (theoretically should) result in a Normal Window
display.

=item B<WorkingDirectory>

The directory in which the targeted program will be executed.
Correspond to the "B<Start in>" field of a Shortcut Properties Dialog
Box.

=back

=head2 Constants

The following constants are exported in the main namespace of your
script using Win32::Shortcut:

=over

=item * SW_SHOWNORMAL

=item * SW_SHOWMAXIMIZED

=item * SW_SHOWMINNOACTIVE

=back

Those constants are the allowed values for the ShowCmd property.



=head1 VERSION HISTORY

B<0.03 (07 Apr 1997)>

=over

=item * The PLL file now comes in 2 versions, one for Perl version
5.001 (build 110) and one for Perl version 5.003 (build 300 and higher,
EXCEPT 304).

=item * Added an installation program which will automatically copy the
right files in the right place.

=back

B<0.02 (21 Jan 1997)>

=over

=item * Added methods matching properties to reduce typing overhead
(eg. Alt-123 and 125...).

=back

B<0.01 (15 Jan 1997)>

=over

=item *

First public release.

=item *

Added "Set" and "Resolve" and the properties "Hotkey", "IconLocation"
and "IconNumber".

=back

B<0.01a (10 Jan 1997)>

=over

=item *

First implementation of the IShellLink interface (wow, it works!); can
"Load", "Save", and modify properties of shortcut files.

=back

=head1 AUTHOR

Aldo Calpini L<dada@perl.it>

=head1 CREDITS

Thanks to: Jesse Dougherty, Dave Roth, ActiveWare, and the
Perl-Win32-Users community.

=head1 DISCLAIMER

I<This program is FREE; you can redistribute, modify, disassemble, or
even reverse engineer this software at your will. Keep in mind,
however, that NOTHING IS GUARANTEED to work and everything you do is AT
YOUR OWN RISK - I will not take responsability for any damage, loss of
money and/or health that may arise from the use of this program!>

This is distributed under the terms of Larry Wall's Artistic License.

=cut
