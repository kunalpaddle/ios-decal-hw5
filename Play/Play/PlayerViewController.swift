//
//  PlayerViewController.swift
//  Play
//
//  Created by Gene Yoo on 11/26/15.
//  Copyright © 2015 cs198-1. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    var tracks: [Track]!
    var scAPI: SoundCloudAPI!
    
    var currentIndex: Int!
    var player: AVPlayer!
    var trackImageView: UIImageView!
    
    var playPauseButton: UIButton!
    var nextButton: UIButton!
    var previousButton: UIButton!
    
    var artistLabel: UILabel!
    var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.whiteColor()

        scAPI = SoundCloudAPI()
        scAPI.loadTracks(didLoadTracks)
        currentIndex = 0
        
        player = AVPlayer()
        
        loadVisualElements()
        loadPlayerButtons()
    }
    
    func loadVisualElements() {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let offset = height - width
        
    
        trackImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0,
            width: width, height: width))
        trackImageView.contentMode = UIViewContentMode.ScaleAspectFill
        trackImageView.clipsToBounds = true
        view.addSubview(trackImageView)
        
        titleLabel = UILabel(frame: CGRect(x: 0.0, y: width + offset * 0.15,
            width: width, height: 20.0))
        titleLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(titleLabel)

        artistLabel = UILabel(frame: CGRect(x: 0.0, y: width + offset * 0.25,
            width: width, height: 20.0))
        artistLabel.textAlignment = NSTextAlignment.Center
        artistLabel.textColor = UIColor.grayColor()
        view.addSubview(artistLabel)
    }
    
    
    func loadPlayerButtons() {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let offset = height - width
    
        let playImage = UIImage(named: "play")?.imageWithRenderingMode(.AlwaysTemplate)
        let pauseImage = UIImage(named: "pause")?.imageWithRenderingMode(.AlwaysTemplate)
        let nextImage = UIImage(named: "next")?.imageWithRenderingMode(.AlwaysTemplate)
        let previousImage = UIImage(named: "previous")?.imageWithRenderingMode(.AlwaysTemplate)
        
        playPauseButton = UIButton(type: UIButtonType.Custom)
        playPauseButton.frame = CGRectMake(width / 2.0 - width / 30.0,
                                           width + offset * 0.5,
                                           width / 15.0,
                                           width / 15.0)
        playPauseButton.setImage(playImage, forState: UIControlState.Normal)
        playPauseButton.setImage(pauseImage, forState: UIControlState.Selected)
        playPauseButton.addTarget(self, action: "playOrPauseTrack:",
            forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(playPauseButton)
        
        previousButton = UIButton(type: UIButtonType.Custom)
        previousButton.frame = CGRectMake(width / 2.0 - width / 30.0 - width / 5.0,
                                          width + offset * 0.5,
                                          width / 15.0,
                                          width / 15.0)
        previousButton.setImage(previousImage, forState: UIControlState.Normal)
        previousButton.addTarget(self, action: "previousTrackTapped:",
            forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(previousButton)

        nextButton = UIButton(type: UIButtonType.Custom)
        nextButton.frame = CGRectMake(width / 2.0 - width / 30.0 + width / 5.0,
                                      width + offset * 0.5,
                                      width / 15.0,
                                      width / 15.0)
        nextButton.setImage(nextImage, forState: UIControlState.Normal)
        nextButton.addTarget(self, action: "nextTrackTapped:",
            forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(nextButton)

    }

    
    func loadTrackElements() {
        let track = tracks[currentIndex]
        asyncLoadTrackImage(track)
        titleLabel.text = track.title
        artistLabel.text = track.artist
    }
    
    /* 
     *  This Method should play or pause the song, depending on the song's state
     *  It should also toggle between the play and pause images by toggling
     *  sender.selected
     * 
     *  If you are playing the song for the first time, you should be creating 
     *  an AVPlayerItem from a url and updating the player's currentitem 
     *  property accordingly.
     */
    func playOrPauseTrack(sender: UIButton) {
        let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        let clientID = NSDictionary(contentsOfFile: path!)?.valueForKey("client_id") as! String
        let track = tracks[currentIndex]
        let url = NSURL(string: "https://api.soundcloud.com/tracks/\(track.id)/stream?client_id=\(clientID)")!
        // FILL ME IN
        if (sender.selected == true) {
            player.pause()
        }
        else {
            if let currentSong = player.currentItem {
                if (player.status == .ReadyToPlay) {
                    player.play()
                }
                else {
                    if (currentSong.status == .Failed) {
                        // Just load the next  song!
                        nextTrackTapped(sender)
                    }
                }
            }
            else {
                print ("hey")
                player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: url))
                player.play()
            }
        }
        //update UI
        playPauseButton.selected = !playPauseButton.selected
    
    }
    
    /* 
     * Called when the next button is tapped. It should check if there is a next
     * track, and if so it will load the next track's data and
     * automatically play the song if a song is already playing
     * Remember to update the currentIndex
     */
    func nextTrackTapped(sender: UIButton) {
        currentIndex! += 1
        
        if currentIndex == tracks.count {
            //Restart the playlist
            currentIndex! = 0
        }
        
        loadTrackElements()
        
        let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        
        let client_id = NSDictionary(contentsOfFile: path!)?.valueForKey("client_id") as! String
        
        let url = NSURL(string: "https://api.soundcloud.com/tracks/\(tracks[currentIndex].id)/stream?client_id=\(client_id)")!
        
        // Make player for new song
        player = AVPlayer(playerItem: AVPlayerItem(URL: url))
        
        if playPauseButton.selected {
            player.play()
        }

        if player.status == .Failed {
            //Next song if something blows up
            nextTrackTapped(sender)
        }

    
    }

    /*
     * Called when the previous button is tapped. It should behave in 2 possible
     * ways:
     *    a) If a song is more than 3 seconds in, seek to the beginning (time 0)
     *    b) Otherwise, check if there is a previous track, and if so it will 
     *       load the previous track's data and automatically play the song if
     *      a song is already playing
     *  Remember to update the currentIndex if necessary
     */

    func previousTrackTapped(sender: UIButton) {
        if player.currentTime().seconds <= 3 {
            
            currentIndex! -= 1
            
            if currentIndex < 0 {
                // rolls back to end of playlist
                currentIndex = tracks.count - 1
            }
            loadTrackElements()
        
            let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        
            let client_id = NSDictionary(contentsOfFile: path!)?.valueForKey("client_id") as! String
        
            let url = NSURL(string: "https://api.soundcloud.com/tracks/\(tracks[currentIndex].id)/stream?client_id=\(client_id)")!
        
        // Make player for new song
            player = AVPlayer(playerItem: AVPlayerItem(URL: url))
            
            if playPauseButton.selected == true {
                player.play()
            }
        
            if player.currentItem!.status == .Failed {
            //Previous song if something blows up
                previousTrackTapped(sender)
            }
        }
        else {
            player.seekToTime(CMTimeMakeWithSeconds(0, 1))
        }
    
    }
    
    
    func asyncLoadTrackImage(track: Track) {
        let url = NSURL(string: track.artworkURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.trackImageView.image = image
                    }
                }
            }
        }
        task.resume()
    }
    
    func didLoadTracks(tracks: [Track]) {
        self.tracks = tracks
        loadTrackElements()
    }
}

