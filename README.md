# Asteroids Lite - Project Report

Below, we give a summarized chronology of what went into building the project, from picking a project topic to the final implementation and presentation. There was a lot to learn, and there were tradeoffs we had to make. In the end, we were quite happy with how things turned out.

## Choosing a project

When the semester project specification was released, we had a list of recommended project topics. We were also encouraged to come up with one of our own if we wanted. The next step would then be to write a project proposal that Prof. Keleher would approve. For group 15, we used a process of elimination to pick what to work on. We actually took a few days to individually think about it, then we had a meeting to decide on which ideas seemed the most interesting to work on. We chose the Asteroids project because, for the most part, we thought it would be fun to build a game.

## Writing the Proposal

After doing a little research about the Asteroids game itself (I had personally never played the Atari version), an idea that stood out was based on leveraging the iPhone’s motion capabilities to build an alternate (but still cool) interface for the game. While staying true to as much of the classic game’s features as we could, we thought this might be an interesting take on it, one that even people who might have played the original game might appreciate. Once we had all our major goals worked out, we submitted our proposal and were approved.

## Deciding on implementation details

Although we had a broad theme worked out, there were still a lot of details in between that we simply had no idea about. For one, how the game played was something I (Tom) needed more information on, as I had never played it before. YouTube was a handy resource in this process.

After developing a better understanding on how the game worked, there was also the question of how we would build the game for the iOS platform. Having never built an iOS game before, I was reluctant to dive immediately into learning about another technology, this one for making games, I had vaguely heard of SpriteKit (saw it in the project specification), and while reading up online, I also came across Metal. I did not end up looking too deep into Metal.

Initially, the idea was to leverage as much of what we had learned from the class and from working on class projects in developing the game. After a little experimentation with this, it became clear that this would not work well for our purposes. I had the idea of building the game sprites using UIBezierPath, but if it can be done, I was unable to figure it out.

As a first prototype, we built a version of the game in JavaScript, following a YouTube tutorial (https://www.youtube.com/watch?v=H9CSWMxJx84). After this, a lot of implementation details were clearer. However, we had still not settled on an implementation plan or platform. However, after doing some tutorials on SpriteKit on the Ray Wenderlich website, it became clear that SpriteKit was really fun to work with, and not a lot of work to learn. After following one more tutorial (https://www.youtube.com/watch?v=0-lM51yI-PA) to gain more of a feel for SpriteKit, and how it might work with something similar to what we were trying to build, we began working on making the app for ourselves.

## Making the Game

The first thing I wanted to make sure to get working and tested was the Core Motion functionality. So I built a small project with a sprite for the ship, and implemented the necessary functionality to get it working quickly. The main reason for this was that we did not have a physical device handy, and so getting this part tested early would give me some confidence that we had taken care of something that would become a potential headache down the line.

I was able to get my hands on an iPhone for a few hours (not easy during these COVID-19 times), and developed some code fragments that worked well enough, if in need of tweaks. The next step was to build out as much of the app on the simulator as we could. Luckily for us, the core motion features were basically the only things requiring physical hardware.

While Deb worked on a base version, and built out much of the game world, I focused on making sure the interactions worked like we wanted. To avoid tripping over each other in development, we settled on a simple strategy of alternating working days, and committing code frequently. I think we were lucky in this implementation because, compared to our initial prototype in JavaScript, SpriteKit’s physics engine did a lot of the heavy lifting already. The remainder of the work left for us simply involved defining core pieces and fitting them together.

Once the game was working well, we added some sounds, put in a main menu screen, and worked on getting it ready for the presentation.

## Presentation

Because we did not have access to an iPhone, we had to record our video demo on an iPad. For some reason we did not investigate, the sprites had some unusual issues on the iPad. The collision bounds skewed toward one edge of the sprites. However, the game worked fine for us on an iPhone simulator. We made sure to explain as much in the demo video. Presenting in class went well, in my opinion.
