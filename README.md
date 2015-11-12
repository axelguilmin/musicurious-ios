# Musicurious
Love the music, be curious.  
With Musicurious you can discover music from all around the world and share your own favorite song!  
The project can be compiled with xCode 7.1 and tested on a iOS9+ device, simply open `musicurious-ios/musicurious-ios.xcodeproj` 

## Tour
The iOS application is composed of three sreens.

#### Map
The first screen is a world map, you can tap any country to select.  
Once a country is selected, the player screen is shown if there is songs from this country, if not the new song screen is presented so you can add a song you like from this country.  
The "I feel lucky" button on the bottom randomly select a song.   
See `MapViewController`
#### Player
The player displays all the song from the selected country, the user can navigate through the song by swipping left or right and tap the "+" to add another song.  
See `CountryViewController` and `SongViewController`
#### New song
To add a song, the user has to provide at least a title and a link from Youtbue (for example _https://www.youtube.com/watch?v=6c-RbGZBnBI_ or _https://youtu.be/6c-RbGZBnBI?t=30s_)  
Closing the keyboard (by tapping outside a textfield), will start a preview of the youtube video if available.   
See `NewSongViewController`

## Origin
I always loved music and I like to discover eclectic songs from all around the world. Unfortunately, radio stations often play the same song again and again, making harder for someone to discover new stuff.  
So the idea of a collaborative "music trip" came to me, and I think it could be a new way to discover interesting vibes.

## Credits
The application is developed by myself (Axel Guilmin) with no license.  
Feel free to fork, use, modify it however you want (Attribution would be much apreciated though).  
However, the videos and musics are distributed by Youtube, no Copyright is intended.  s
Special thanks to Giles Van Gruisen (http://gilesvangruisen.com), the author of YouTubePlayer, the library used in Musicurious to play the videos.

## Thoughts

#### Frictions
Obviously, there is a lot of friction to add a song, in a next version I would like to allow the user to search youtube video from the app.
Also, some videos might not be available from your location, this is due to restrictions from Youtube.

#### Going further
There is more ideas to explore.
First, Adding a support for several playlists (or map) so one could create a playlist for the rock songs in the world, or the candidates at Eurovision for example. 
Also, for the USA, Canada, Australia, etc; I'd like to give the posibility to select a state instead of the whole country. 


