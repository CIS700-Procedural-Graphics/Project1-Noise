A procedural noise cloud that dances and changes color with music. Returns to default noise based animation on pausing the music.

The color is chosen by interpolating between 1,1,1 (white) and the color from the GUI. This interpolation is done using noise value and audio data (when music is playing). 
The positions of the mesh vertices are also offset using audio data when the music is playing.

Noise used is multi-octave lattice value noise. The noise calculations and vertex manipulations are done in shaders.

Music:
Hachiko (The Faithtful Dog) by The Kyoto Connection
shared under Attribution-ShareAlike 3.0 International License.
(https://creativecommons.org/licenses/by-sa/3.0/legalcode)

See helplog.md for references.
