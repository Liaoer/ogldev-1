use strictures;

package Texture;

use lib '../arcsyn/framework';

use Moo;
use OpenGL::Image;
use OpenGL::Debug qw(
  GL_RGB
  GL_RGBA
  GL_UNSIGNED_BYTE
  GL_TEXTURE_MIN_FILTER
  GL_LINEAR
  GL_TEXTURE_MAG_FILTER

  glGenTextures_p
  glBindTexture
  glTexImage2D_c
  glTexParameterf
  glActiveTextureARB
);

has TextureTarget => ( is => 'ro', required => 1 );
has FileName      => ( is => 'ro', required => 1 );
has pImage        => ( is => 'rw' );
has blob          => ( is => 'rw' );
has textureObj    => ( is => 'rw' );

sub Load {
    my ( $self ) = @_;

    my $tex = OpenGL::Image->new( engine => 'Magick', source => $self->FileName );
    die sprintf "\nCould not load texture file: '%s'.\n", $self->FileName if !$tex;
    $self->blob( $tex->Ptr );

    my ( $ifmt, $fmt, $type ) = $tex->Get( 'gl_internalformat', 'gl_format', 'gl_type' );
    my ( $w, $h ) = $tex->Get( 'width', 'height' );

    $self->textureObj( glGenTextures_p( 1 ) );
    glBindTexture( $self->TextureTarget, $self->textureObj );
    glTexImage2D_c( $self->TextureTarget, 0, $ifmt, $w, $h, 0, $fmt, $type, $self->blob );
    glTexParameterf( $self->TextureTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameterf( $self->TextureTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glBindTexture( $self->TextureTarget, 0 );

    return 1;
}

sub Bind {
    my ( $self, $TextureUnit ) = @_;
    glActiveTextureARB( $TextureUnit );
    glBindTexture( $self->TextureTarget, $self->textureObj );
}

1;
