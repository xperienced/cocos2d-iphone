//
// Particle Batch DemoBatch
// a cocos2d example
// http://www.cocos2d-iphone.org
//
//created by Marco Tillemans

// local import
#import "ParticleTestBatched.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define PARTICLE_FIRE_NAME @"fire.pvr"
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#define PARTICLE_FIRE_NAME @"fire.png"
#endif
enum {
	kTagLabelAtlas = 1,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"DemoBatchFlower",
	@"DemoBatchGalaxy",
	@"DemoBatchFirework",
	@"DemoBatchSpiral",
	@"DemoBatchSun",
	@"DemoBatchMeteor",
	@"DemoBatchFire",
	@"DemoBatchSmoke",
	@"DemoBatchExplosion",
	@"DemoBatchSnow",
	@"DemoBatchRain",
	@"DemoBatchBigFlower",
	@"DemoBatchRotFlower",
	@"DemoBatchModernArt",
	@"DemoBatchRing",
	
	@"ParallaxParticle",
	
	@"ParticleDesigner1",
	@"ParticleDesigner2",
	@"ParticleDesigner3",
	@"ParticleDesigner4",
	@"ParticleDesigner5",
	@"ParticleDesigner6",
	@"ParticleDesigner7",
	@"ParticleDesigner8",
	@"ParticleDesigner9",
	@"ParticleDesigner10",
	@"ParticleDesigner11",
	@"ParticleDesigner12",
    @"StayPut",
	
	@"RadiusMode1",
	@"RadiusMode2",
	@"Issue704",
	@"Issue872",
	@"Issue870",
	@"MultipleParticleSystems",
	@"MultipleParticleSystemsBatched",	
	@"AddAndDeleteParticleSystems",
	@"ReorderParticleSystems",
	@"AnimatedParticles",
   	@"LotsOfAnimatedParticles",
	
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

@implementation ParticleDemoBatch

@synthesize emitter=emitter_;
-(id) init
{
	if( (self=[super initWithColor:ccc4(127,127,127,255)] )) {
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
		
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:100];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:100];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}			
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenuItemToggle *item4 = [CCMenuItemToggle itemWithTarget:self selector:@selector(toggleCallback:) items:
								   [CCMenuItemFont itemFromString: @"Free Movement"],
								   [CCMenuItemFont itemFromString: @"Relative Movement"],
								   [CCMenuItemFont itemFromString: @"Grouped Movement"],
								   
								   nil];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, item4, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		item4.position = ccp( 0, 100);
		item4.anchorPoint = ccp(0,0);
		
		[self addChild: menu z:100];	
		
		CCLabelAtlas *labelAtlas = [CCLabelAtlas labelWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
		[self addChild:labelAtlas z:100 tag:kTagLabelAtlas];
		labelAtlas.position = ccp(s.width-66,50);
		
		// moving background
		background = [CCSprite spriteWithFile:@"background3.png"];
		[self addChild:background z:5];
		[background setPosition:ccp(s.width/2, s.height-180)];
		
		id move = [CCMoveBy actionWithDuration:4 position:ccp(300,0)];
		id move_back = [move reverse];
		id seq = [CCSequence actions: move, move_back, nil];
		[background runAction:[CCRepeatForever actionWithAction:seq]];
		
		batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:background.texture capacity:500 useQuad:YES additiveBlending:NO]; 
		[background addChild:batchNode_]; 
		
		[self scheduleUpdate];
	}
	
	return self;
}

- (void) dealloc
{
	//[batchNode_ release];
	[emitter_ release];
	[super dealloc];
}


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	[self ccTouchEnded:touch withEvent:event];
	
	// claim the touch
	return YES;
}
- (void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}

- (void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
	
	CGPoint pos = CGPointZero;
	
	if( background )
		pos = [background convertToWorldSpace:CGPointZero];
	emitter_.position = ccpSub(convertedLocation, pos);	
}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)


-(BOOL) ccMouseDragged:(NSEvent *)event
{
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	
	CGPoint pos = CGPointZero;
	
	if( background )
		pos = [background convertToWorldSpace:CGPointZero];
	emitter_.position = ccpSub(convertedLocation, pos);	
	// swallow the event. Don't propagate it
	return YES;	
}
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelAtlas];
	
	NSString *str = [NSString stringWithFormat:@"%4d", emitter_.particleCount];
	[atlas setString:str];
}

-(NSString*) title
{
	return @"No title";
}
-(NSString*) subtitle
{
	return @"Tap the screen";
}

-(void) toggleCallback: (id) sender
{
	if( emitter_.positionType == kCCPositionTypeGrouped )
		emitter_.positionType = kCCPositionTypeFree;
	else if( emitter_.positionType == kCCPositionTypeFree )
		emitter_.positionType = kCCPositionTypeRelative;
	else if( emitter_.positionType == kCCPositionTypeRelative )
		emitter_.positionType = kCCPositionTypeGrouped;
}

-(void) restartCallback: (id) sender
{
	//	Scene *s = [Scene node];
	//	[s addChild: [restartAction() node]];
	//	[[Director sharedDirector] replaceScene: s];
	
	[emitter_ resetSystem];
	//	[emitter_ stopSystem];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) setEmitterPosition
{
	if( CGPointEqualToPoint( emitter_.sourcePosition, CGPointZero ) ) 
		emitter_.position = ccp(200, 70);
}

@end

#pragma mark -

@implementation DemoBatchFirework
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleFireworks node];
	
	
	//[background addChild:emitter_ z:10];
	
	// testing "alpha" blending in premultiplied images
	//	emitter_.blendFunc = (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars.png"];
	emitter_.blendAdditive = YES;
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ additiveBlending];
	[batchNode_ addChild:emitter_]; 
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleFireworks";
}
@end

#pragma mark -

@implementation DemoBatchFire
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleFire node];
	[batchNode_ removeAllChildrenWithCleanup:YES];
	
	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
	CGPoint p = emitter_.position;
	emitter_.position = ccp(p.x, 100);
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ additiveBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"ParticleFire";
}
@end

#pragma mark -

@implementation DemoBatchSun
-(void) onEnter
{
	[super onEnter];
	[batchNode_ removeAllChildrenWithCleanup:YES];
	
	self.emitter = [CCParticleSun node];
	self.emitter.scale = 1.5f;
	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ additiveBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"ParticleSun";
}
@end

#pragma mark -

@implementation DemoBatchGalaxy
-(void) onEnter
{
	[super onEnter];
	//[batchNode_ removeAllChildrenWithCleanup:YES];
	self.emitter = [CCParticleGalaxy node];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ additiveBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"ParticleGalaxy";
}
@end

#pragma mark -

@implementation DemoBatchFlower
-(void) onEnter
{
	[super onEnter];

	self.emitter = [CCParticleFlower node];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ additiveBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"ParticleFlower";
}
@end

#pragma mark -

@implementation DemoBatchBigFlower
-(void) onEnter
{
	[super onEnter];
	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:50];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	// duration
	emitter_.duration = kCCParticleDurationInfinity;
	
	// Gravity Mode: gravity
	emitter_.gravity = CGPointZero;
	
	// Set "Gravity" mode (default one)
	emitter_.emitterMode = kCCParticleModeGravity;
	
	// Gravity Mode: speed of particles
	emitter_.speed = 160;
	emitter_.speedVar = 20;
	
	// Gravity Mode: radial
	emitter_.radialAccel = -120;
	emitter_.radialAccelVar = 0;
	
	// Gravity Mode: tagential
	emitter_.tangentialAccel = 30;
	emitter_.tangentialAccelVar = 0;
	
	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 360;
	
	// emitter position
	emitter_.position = ccp(160,240);
	emitter_.posVar = CGPointZero;
	
	// life of particles
	emitter_.life = 4;
	emitter_.lifeVar = 1;
	
	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 0;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter_.endColorVar = endColorVar;
	
	// size, in pixels
	emitter_.startSize = 80.0f;
	emitter_.startSizeVar = 40.0f;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;
	
	// additive
	emitter_.blendAdditive = YES;
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ additiveBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"Big Particles";
}
@end

#pragma mark -

@implementation DemoBatchRotFlower
-(void) onEnter
{
	[super onEnter];
	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:300];

	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars2-grayscale.png"];
	
	// duration
	emitter_.duration = kCCParticleDurationInfinity;
	
	// Set "Gravity" mode (default one)
	emitter_.emitterMode = kCCParticleModeGravity;
	
	// Gravity mode: gravity
	emitter_.gravity = CGPointZero;
	
	// Gravity mode: speed of particles
	emitter_.speed = 160;
	emitter_.speedVar = 20;
	
	// Gravity mode: radial
	emitter_.radialAccel = -120;
	emitter_.radialAccelVar = 0;
	
	// Gravity mode: tagential
	emitter_.tangentialAccel = 30;
	emitter_.tangentialAccelVar = 0;
	
	// emitter position
	emitter_.position = ccp(160,240);
	emitter_.posVar = CGPointZero;
	
	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 360;
	
	// life of particles
	emitter_.life = 3;
	emitter_.lifeVar = 1;
	
	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 2000;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter_.endColorVar = endColorVar;
	
	// size, in pixels
	emitter_.startSize = 30.0f;
	emitter_.startSizeVar = 00.0f;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;
	
	// additive
	emitter_.blendAdditive = NO;
	
	[self setEmitterPosition];
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ normalBlending];	
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"Spinning Particles";
}
@end

#pragma mark -

@implementation DemoBatchMeteor
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleMeteor node];
	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
	
	[self setEmitterPosition];
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ additiveBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"ParticleMeteor";
}
@end

#pragma mark -

@implementation DemoBatchSpiral
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSpiral node];
	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
	
	[self setEmitterPosition];
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ normalBlending];	
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"ParticleSpiral";
}
@end

#pragma mark -

@implementation DemoBatchExplosion
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleExplosion node];

	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	emitter_.autoRemoveOnFinish = YES;
	
	[self setEmitterPosition];
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ normalBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"ParticleExplosion";
}
@end

#pragma mark -

@implementation DemoBatchSmoke
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSmoke node];
	
	
	CGPoint p = emitter_.position;
	emitter_.position = ccp( p.x, 100);
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ normalBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"ParticleSmoke";
}
@end

#pragma mark -

@implementation DemoBatchSnow
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSnow node];
	
	CGPoint p = emitter_.position;
	emitter_.position = ccp( p.x, p.y-110);
	emitter_.life = 3;
	emitter_.lifeVar = 1;
	
	// gravity
	emitter_.gravity = ccp(0,-10);
	
	// speed of particles
	emitter_.speed = 130;
	emitter_.speedVar = 30;
	
	
	ccColor4F startColor = emitter_.startColor;
	startColor.r = 0.9f;
	startColor.g = 0.9f;
	startColor.b = 0.9f;
	emitter_.startColor = startColor;
	
	ccColor4F startColorVar = emitter_.startColorVar;
	startColorVar.b = 0.1f;
	emitter_.startColorVar = startColorVar;
	
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;
	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"snow.png"];
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ normalBlending];
	[batchNode_ addChild:emitter_]; 
	
}
-(NSString *) title
{
	return @"ParticleSnow";
}
@end

#pragma mark -

@implementation DemoBatchRain
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleRain node];

	
	CGPoint p = emitter_.position;
	emitter_.position = ccp( p.x, p.y-100);
	emitter_.life = 4;
	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ normalBlending];
	[batchNode_ addChild:emitter_]; 
	
}
-(NSString *) title
{
	return @"ParticleRain";
}
@end

#pragma mark -

@implementation DemoBatchModernArt
-(void) onEnter
{
	[super onEnter];
	emitter_ = [[CCParticleSystemPoint alloc] initWithTotalParticles:1000];

	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	// duration
	emitter_.duration = kCCParticleDurationInfinity;
	
	// Gravity mode
	emitter_.emitterMode = kCCParticleModeGravity;
	
	// Gravity mode: gravity
	emitter_.gravity = ccp(0,0);
	
	// Gravity mode: radial
	emitter_.radialAccel = 70;
	emitter_.radialAccelVar = 10;
	
	// Gravity mode: tagential
	emitter_.tangentialAccel = 80;
	emitter_.tangentialAccelVar = 0;
	
	// Gravity mode: speed of particles
	emitter_.speed = 50;
	emitter_.speedVar = 10;
	
	// angle
	emitter_.angle = 0;
	emitter_.angleVar = 360;
	
	// emitter position
	emitter_.position = ccp( s.width/2, s.height/2);
	emitter_.posVar = CGPointZero;
	
	// life of particles
	emitter_.life = 2.0f;
	emitter_.lifeVar = 0.3f;
	
	// emits per frame
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter_.endColorVar = endColorVar;
	
	// size, in pixels
	emitter_.startSize = 1.0f;
	emitter_.startSizeVar = 1.0f;
	emitter_.endSize = 32.0f;
	emitter_.endSizeVar = 8.0f;
	
	// texture
	//	emitter_.texture = [[TextureCache sharedTextureCache] addImage:@"fire-grayscale.png"];
	
	// additive
	emitter_.blendAdditive = NO;
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ normalBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"Varying size";
}

-(NSString *) subTitle
{
	return @"doesn't work, is a point particle system";
}
@end

#pragma mark -

@implementation DemoBatchRing
-(void) onEnter
{
	[super onEnter];
	emitter_ = [[CCParticleFlower alloc] initWithTotalParticles:500];

	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	emitter_.lifeVar = 0;
	emitter_.life = 10;
	emitter_.speed = 100;
	emitter_.speedVar = 0;
	emitter_.emissionRate = 10000;
	
	[self setEmitterPosition];
	
	[batchNode_ setTexture:emitter_.texture]; 
	
	[batchNode_ additiveBlending];
	[batchNode_ addChild:emitter_]; 
}
-(NSString *) title
{
	return @"Ring DemoBatch";
}
@end

#pragma mark -

@implementation ParallaxParticle
-(void) onEnter
{
	[super onEnter];
	
	[[background parent] removeChild:background cleanup:YES];
	background = nil;
	
	CCParallaxNode *p = [CCParallaxNode node];
	[self addChild:p z:5];
	
	CCSprite *p1 = [CCSprite spriteWithFile:@"background3.png"];
	background = p1;
	
	CCSprite *p2 = [CCSprite spriteWithFile:@"background3.png"];
	
	[p addChild:p1 z:1 parallaxRatio:ccp(0.5f,1) positionOffset:ccp(0,250)];
	[p addChild:p2 z:2 parallaxRatio:ccp(1.5f,1) positionOffset:ccp(0,50)];
	
	
	emitter_ = [[CCParticleFlower alloc] initWithTotalParticles:500];

	[emitter_ setPosition:ccp(250,200)];
	
	
	
	id move = [CCMoveBy actionWithDuration:4 position:ccp(300,0)];
	id move_back = [move reverse];
	id seq = [CCSequence actions: move, move_back, nil];
	[p runAction:[CCRepeatForever actionWithAction:seq]];	
	
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:100 useQuad:YES additiveBlending:NO]; 
	[p1 addChild:batchNode_];
	
	[batchNode_ additiveBlending];
	[batchNode_ addChild:emitter_]; 
	
	//new batchNode
	CCParticleSystem* par = [[CCParticleSun alloc] initWithTotalParticles:250];

	
	CCParticleBatchNode* bNode = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:300 useQuad:YES additiveBlending:YES]; 
	[p2 addChild:bNode];
	[bNode addChild:par];
 	
	[par release];
	
	
}

-(NSString *) title
{
	return @"Parallax + Particles";
}
@end

#pragma mark -

@implementation ParticleDesigner1
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/SpookyPeas.plist"];
	
	// custom spinning
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 360;
	emitter_.endSpin = 720;
	emitter_.endSpinVar = 360;
	
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:NO]; 
	[self addChild:batchNode_];
	

	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Spooky Peas";
}
@end

#pragma mark -

@implementation ParticleDesigner2
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/SpinningPeas.plist"];
	
	
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:NO]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
	
}

-(NSString *) title
{
	return @"PD: Spinning Peas";
}
@end


#pragma mark -

@implementation ParticleDesigner3
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/LavaFlow.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:YES]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
	
}

-(NSString *) title
{
	return @"PD: Lava Flow";
}
@end

#pragma mark -

@implementation ParticleDesigner4
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/ExplodingRing.plist"];

	
	[self removeChild:background cleanup:YES];
	background = nil;
	
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:YES]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Exploding Ring";
}
@end

#pragma mark -

@implementation ParticleDesigner5
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Comet.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:YES]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Comet";
}
@end

#pragma mark -

@implementation ParticleDesigner6
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/BurstPipe.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:YES]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Burst Pipe";
}
@end

#pragma mark -

@implementation ParticleDesigner7
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/BoilingFoam.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:YES]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Boiling Foam";
}
@end

#pragma mark -

@implementation ParticleDesigner8
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Flower.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:YES]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Flower";
}

-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}

@end

#pragma mark -

@implementation ParticleDesigner9
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Spiral.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:NO]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Blur Spiral";
}

-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}

@end

#pragma mark -

@implementation ParticleDesigner10
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Galaxy.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:YES]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Galaxy";
}
-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}
@end

#pragma mark -

@implementation ParticleDesigner11
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/debian.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:NO]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Debian";
}
-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}
@end

#pragma mark -

@implementation ParticleDesigner12
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Phoenix.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:YES]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: Phoenix";
}
-(NSString*) subtitle
{
	return @"Testing radial and duration";
}
@end

@implementation StayPut
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/StayPut.plist"];
    self.emitter.posVar = ccp(0.f,0.f); 
    self.emitter.totalParticles = 1; 
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:1 useQuad:YES additiveBlending:NO]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
}

-(NSString *) title
{
	return @"PD: StayPut?";
}
-(NSString*) subtitle
{
	return @"Testing position in retina (wait)";
}
@end

#pragma mark -

@implementation RadiusMode1
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:200];

	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	// duration
	emitter_.duration = kCCParticleDurationInfinity;
	
	// radius mode
	emitter_.emitterMode = kCCParticleModeRadius;
	
	// radius mode: start and end radius in pixels
	emitter_.startRadius = 0;
	emitter_.startRadiusVar = 0;
	emitter_.endRadius = 160;
	emitter_.endRadiusVar = 0;
	
	// radius mode: degrees per second
	emitter_.rotatePerSecond = 180;
	emitter_.rotatePerSecondVar = 0;
	
	
	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 0;
	
	// emitter position
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter_.position = ccp( size.width/2, size.height/2);
	emitter_.posVar = CGPointZero;
	
	// life of particles
	emitter_.life = 5;
	emitter_.lifeVar = 0;
	
	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 0;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter_.endColorVar = endColorVar;
	
	// size, in pixels
	emitter_.startSize = 32;
	emitter_.startSizeVar = 0;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;
	
	// additive
	emitter_.blendAdditive = NO;

	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:NO]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 	
}


-(NSString *) title
{
	return @"Radius Mode: Spiral";
}
@end

#pragma mark -

@implementation RadiusMode2
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	//200
	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:200];
	
	
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	// duration
	emitter_.duration = kCCParticleDurationInfinity;
	
	// radius mode
	emitter_.emitterMode = kCCParticleModeRadius;
	
	// radius mode: 100 pixels from center
	emitter_.startRadius = 100;
	emitter_.startRadiusVar = 0;
	emitter_.endRadius = kCCParticleStartRadiusEqualToEndRadius;
	emitter_.endRadiusVar = 0;	// not used when start == end
	
	// radius mode: degrees per second
	// 45 * 4 seconds of life = 180 degrees
	emitter_.rotatePerSecond = 45;
	emitter_.rotatePerSecondVar = 0;
	
	
	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 0;
	
	// emitter position
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter_.position = ccp( size.width/2, size.height/2);
	emitter_.posVar = CGPointZero;
	
	// life of particles
	emitter_.life = 4;
	emitter_.lifeVar = 0;
	
	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 0;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter_.endColorVar = endColorVar;
	
	// size, in pixels
	emitter_.startSize = 32;
	emitter_.startSizeVar = 0;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;
	
	// additive
	emitter_.blendAdditive = NO;
	
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:NO]; 
	[self addChild:batchNode_];

	
	[batchNode_ addChild:emitter_]; 	
}

-(NSString *) title
{
	return @"Radius Mode: Semi Circle";
}
@end

#pragma mark -

@implementation Issue704
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:100];

	emitter_.duration = kCCParticleDurationInfinity;
	
	// radius mode
	emitter_.emitterMode = kCCParticleModeRadius;
	
	// radius mode: 50 pixels from center
	emitter_.startRadius = 50;
	emitter_.startRadiusVar = 0;
	emitter_.endRadius = kCCParticleStartRadiusEqualToEndRadius;
	emitter_.endRadiusVar = 0;	// not used when start == end
	
	// radius mode: degrees per second
	// 45 * 4 seconds of life = 180 degrees
	emitter_.rotatePerSecond = 0;
	emitter_.rotatePerSecondVar = 0;
	
	
	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 0;
	
	// emitter position
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter_.position = ccp( size.width/2, size.height/2);
	emitter_.posVar = CGPointZero;
	
	// life of particles
	emitter_.life = 5;
	emitter_.lifeVar = 0;
	
	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 0;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter_.endColorVar = endColorVar;
	
	// size, in pixels
	emitter_.startSize = 16;
	emitter_.startSizeVar = 0;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;
	
	// additive
	emitter_.blendAdditive = NO;
	
	id rot = [CCRotateBy actionWithDuration:16 angle:360];
	[emitter_ runAction: [CCRepeatForever actionWithAction:rot] ];
	
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:NO]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; }

-(NSString *) title
{
	return @"Issue 704. Free + Rot";
}

-(NSString*) subtitle
{
	return @"Emitted particles should not rotate";
}
@end

#pragma mark -

@implementation Issue872
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	emitter_ = [[CCParticleSystemQuad alloc] initWithFile:@"Particles/Upsidedown.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:YES]; 
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; }

-(NSString *) title
{
	return @"Issue 872. UpsideDown";
}

-(NSString*) subtitle
{
	return @"Particles should NOT be Upside Down. M should appear, not W.";
}
@end

#pragma mark -

@implementation Issue870
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	CCParticleSystemQuad *system = [[CCParticleSystemQuad alloc] initWithFile:@"Particles/SpinningPeas.plist"];
	
	[system setTexture: [[CCTextureCache sharedTextureCache] addImage:@"particles.png"] withRect:CGRectMake(0,0,32,32)];

	
	emitter_ = system;
	
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithTexture:emitter_.texture capacity:500 useQuad:YES additiveBlending:NO]; 
	//the texture particles is premultiplied according to the loading code, but it still gives incorrect results
	[batchNode_ switchBlendingBetweenMultipliedAndPreMultiplied];
	[self addChild:batchNode_];
	
	
	[batchNode_ addChild:emitter_]; 
	
	index = 0;
	
	[self schedule:@selector(updateQuads:) interval:2];
}

-(void) updateQuads:(ccTime)dt
{
	index = (index + 1) % 4;
	CGRect rect = CGRectMake(index*32, 0,32,32);
	
	CCParticleSystemQuad *system = (CCParticleSystemQuad*) emitter_;
	[system setTexture:[emitter_ texture] withRect:rect];
}

-(NSString *) title
{
	return @"Issue 870. SubRect";
}

-(NSString*) subtitle
{
	return @"Every 2 seconds the particle should change";
}
@end

@implementation MultipleParticleSystems

-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	[[CCTextureCache sharedTextureCache] addImage:@"particles.png"]; 
	
	for (int i = 0; i<5; i++) {
		CCParticleSystemQuad *particleSystem = [CCParticleSystemQuad 
												particleWithFile:@"Particles/SpinningPeas.plist"];
	
		[particleSystem setTexture:[[CCTextureCache sharedTextureCache] textureForKey:@"particles.png"]]; 
		particleSystem.position = ccp(i*50 ,i*50);
		
		particleSystem.positionType = kCCPositionTypeGrouped;
		[self addChild:particleSystem];
	}
	
	emitter_ = nil;
	
}

-(NSString *) title
{
	return @"Multiple particle systems";
}

-(NSString*) subtitle
{
	return @"FPS should be lower than next test";
}

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelAtlas];
	
	uint count = 0; 
	CCNode* item;
	CCARRAY_FOREACH(children_, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}

@end

@implementation MultipleParticleSystemsBatched

-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	CGRect rect = CGRectMake(0.f,0.f,0.f,0.f);
	CCParticleBatchNode *batchNode = [[CCParticleBatchNode alloc] initWithFile:@"particles.png" capacity:3000 useQuad:YES additiveBlending:NO];
	//particles is loaded as pre multiplied, but using pre multiplied blending mode gives incorrect results
	[batchNode switchBlendingBetweenMultipliedAndPreMultiplied];
	
	[self addChild:batchNode z:1 tag:2];
	
	for (int i = 0; i<5; i++) {

		CCParticleSystemQuad *particleSystem = [CCParticleSystemQuad particleWithFile:@"Particles/SpinningPeas.plist" batchNode:batchNode rect:rect];
	
		particleSystem.positionType = kCCPositionTypeGrouped;		 
		[particleSystem setTexture:[[CCTextureCache sharedTextureCache] textureForKey:@"particles.png"]]; 
		particleSystem.position = ccp(i*50 ,i*50);
		
		[batchNode addChild:particleSystem];
	}
	
	[batchNode release];
	
	emitter_ = nil;
}

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelAtlas];
	
	uint count = 0; 
	CCNode* item;
	CCNode* batchNode = [self getChildByTag:2];
	CCARRAY_FOREACH(batchNode.children, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}

-(NSString *) title
{
	return @"Multiple particle systems batched";
}

-(NSString*) subtitle
{
	return @"should perform better than previous test";
}
@end

@implementation AddAndDeleteParticleSystems

-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	CGRect rect = CGRectMake(0.f,0.f,0.f,0.f);
	//adds the texture inside the plist to the texture cache
	[CCParticleBatchNode extractTextureFromPlist:@"Particles/Spiral.plist"];
	batchNode_ = [CCParticleBatchNode particleBatchNodeWithFile:@"Spiral.png" capacity:16000 useQuad:YES additiveBlending:NO];
	
	[self addChild:batchNode_ z:1 tag:2];
	
	for (int i = 0; i<6; i++) {
		
		CCParticleSystemQuad *particleSystem = [CCParticleSystemQuad particleWithFile:@"Particles/Spiral.plist" batchNode:batchNode_ rect:rect];
		
		particleSystem.positionType = kCCPositionTypeGrouped;		 
		particleSystem.totalParticles = 200;
		
		particleSystem.position = ccp(i*15 +100,i*15+100);
		
		uint randZ = arc4random() % 100; 
		[batchNode_ addChild:particleSystem z:randZ tag:-1];
		
	}
	
	[self schedule:@selector(removeSystem) interval:0.5f];
	emitter_ = nil;
	
}

- (void) removeSystem
{
	if ([[batchNode_ children] count] > 0) 
	{
		
		/*CCARRAY_FOREACH([[batchNode_ children],aSystem) 
		 {
		 CCLOG(@"pos %f %f, atlas %i",system.position.x,system.position.y,system.atlasIndex); 
		 }*/
		CCLOG(@"remove random system");
		uint rand = arc4random() % ([[batchNode_ children] count] - 1);
		[batchNode_ removeChild:[[batchNode_ children] objectAtIndex:rand] cleanup:YES];
		CCParticleSystemQuad *particleSystem = [CCParticleSystemQuad particleWithFile:@"Particles/Spiral.plist" batchNode:batchNode_ rect:CGRectMake(0.f,0.f,0.f,0.f)];
		
		//add new
		
		particleSystem.positionType = kCCPositionTypeGrouped;		 
		particleSystem.totalParticles = 200;
		
		particleSystem.position = ccp(arc4random() % 300 ,arc4random() % 400);

		CCLOG(@"add a new system");
		uint randZ = arc4random() % 100; 
		[batchNode_ addChild:particleSystem z:randZ tag:-1];
	}
}

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelAtlas];
	
	uint count = 0; 
	CCNode* item;
	CCNode* batchNode = [self getChildByTag:2];
	CCARRAY_FOREACH(batchNode.children, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}

-(NSString *) title
{
	return @"add and remove";
}

-(NSString*) subtitle
{
	return @"every 2 sec 1 system disappear, 1 appears";
}
@end



@implementation ReorderParticleSystems

-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	CGRect rect = CGRectMake(0.f,0.f,0.f,0.f);
	batchNode_ = [CCParticleBatchNode  particleBatchNodeWithFile:@"stars-grayscale.png" capacity:3000 useQuad:YES additiveBlending:NO];
	
	[self addChild:batchNode_ z:1 tag:2];

	
	for (int i = 0; i<2; i++) {
		
		CCParticleSystemQuad* particleSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:200 batchNode:batchNode_ rect:rect];
		
		// duration
		particleSystem.duration = kCCParticleDurationInfinity;
		
		// radius mode
		particleSystem.emitterMode = kCCParticleModeRadius;
		
		// radius mode: 100 pixels from center
		particleSystem.startRadius = 100;
		particleSystem.startRadiusVar = 0;
		particleSystem.endRadius = kCCParticleStartRadiusEqualToEndRadius;
		particleSystem.endRadiusVar = 0;	// not used when start == end
		
		// radius mode: degrees per second
		// 45 * 4 seconds of life = 180 degrees
		particleSystem.rotatePerSecond = 45;
		particleSystem.rotatePerSecondVar = 0;
		
		
		// angle
		particleSystem.angle = 90;
		particleSystem.angleVar = 0;
		
		// emitter position
				particleSystem.posVar = CGPointZero;
		
		// life of particles
		particleSystem.life = 4;
		particleSystem.lifeVar = 0;
		
		// spin of particles
		particleSystem.startSpin = 0;
		particleSystem.startSpinVar = 0;
		particleSystem.endSpin = 0;
		particleSystem.endSpinVar = 0;
		
		// color of particles
		ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
		particleSystem.startColor = startColor;
		
		ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
		particleSystem.startColorVar = startColorVar;
		
		ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
		particleSystem.endColor = endColor;
		
		ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
		particleSystem.endColorVar = endColorVar;
		
		// size, in pixels
		particleSystem.startSize = 32;
		particleSystem.startSizeVar = 0;
		particleSystem.endSize = kCCParticleStartSizeEqualToEndSize;
		
		// emits per second
		particleSystem.emissionRate = particleSystem.totalParticles/particleSystem.life;
		
		// additive

		particleSystem.position = ccp(i*10+120 ,200);
		
		
		[batchNode_ addChild:particleSystem];
		[particleSystem setPositionType:kCCPositionTypeFree];
		
		[particleSystem release];
		
		//[pBNode addChild:particleSystem z:10 tag:0];
		
	}
	
	[self schedule:@selector(reorderSystem:) interval:2];
	emitter_ = nil;
	
}

- (void) reorderSystem:(ccTime) time
{
	CCParticleSystem* system = [[batchNode_ children] objectAtIndex:1];
	[batchNode_ reorderChild:system z:[system zOrder] - 1]; 	
}


-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelAtlas];
	
	uint count = 0; 
	CCNode* item;
	CCNode* batchNode = [self getChildByTag:2];
	CCARRAY_FOREACH(batchNode.children, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}

-(NSString *) title
{
	return @"reorder systems";
}

-(NSString*) subtitle
{
	return @"changes every 2 seconds";
}
@end

@implementation AnimatedParticles
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	CGRect rect = CGRectMake(0.f,0.f,0.f,0.f);
	batchNode_ = [CCParticleBatchNode  particleBatchNodeWithFile:@"animations/animated_particles.png" capacity:4 useQuad:YES additiveBlending:NO];
	
	[self addChild:batchNode_ z:1 tag:2];
	
	
	CCSpriteFrameCache* sfc = [CCSpriteFrameCache sharedSpriteFrameCache];
	[sfc addSpriteFramesWithFile:@"animations/animated_particles.plist"];
	
	CCAnimation* anim2 = [CCAnimation animation];
	
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_1.png"] delay:0.5f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_2.png"] delay:0.5f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_3.png"] delay:0.5f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_4.png"] delay:0.5f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_5.png"] delay:0.5f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_4.png"] delay:0.5f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_3.png"] delay:0.5f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_2.png"] delay:0.5f];
	
	//new properties in plist define startScale, startScaleVar, endScale, endScaleVar
	for (int i = 0; i < 4; i++)
	{
		CCParticleSystemQuad *system = [CCParticleSystemQuad particleWithFile:@"Particles/OneParticle.plist" batchNode:batchNode_ rect:rect];
		system.emissionRate = 1.f;
		[system setPosition:ccp(30+i*60,200)];
		[system setAnimation:anim2 withAnchorPoint:ccp(0.5f,0.0f)];
		[system setAnimationType:i]; 
		
		[batchNode_ addChild: system z:10];
		
	}	
}



-(NSString *) title
{
	return @"AnimatedParticles";
}

-(NSString*) subtitle
{
	return @"4 modes";
}

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelAtlas];
	
	uint count = 0; 
	CCNode* item;
	CCNode* batchNode = [self getChildByTag:2];
	CCARRAY_FOREACH(batchNode.children, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}
@end

@implementation LotsOfAnimatedParticles
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	CGRect rect = CGRectMake(0.f,0.f,0.f,0.f);
	batchNode_ = [CCParticleBatchNode  particleBatchNodeWithFile:@"animations/animated_particles.png" capacity:4 useQuad:YES additiveBlending:NO];
	
	[self addChild:batchNode_ z:1 tag:2];
	
	
	CCSpriteFrameCache* sfc = [CCSpriteFrameCache sharedSpriteFrameCache];
	[sfc addSpriteFramesWithFile:@"animations/animated_particles.plist"];
	
	CCAnimation* anim2 = [CCAnimation animation];
	
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_1.png"] delay:0.3f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_2.png"] delay:0.3f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_3.png"] delay:0.3f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_4.png"] delay:0.3f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_5.png"] delay:0.3f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_4.png"] delay:0.3f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_3.png"] delay:0.3f];
	[anim2 addFrame:[sfc spriteFrameByName:@"coco_2.png"] delay:0.3f];
		
	CCParticleSystemQuad *system = [CCParticleSystemQuad particleWithFile:@"Particles/SparkParticle.plist" batchNode:batchNode_ rect:rect];
	system.emissionRate = 1.f;
	[system setPosition:ccp(130,200)];
    [system setEmissionRate:500];
    [system setPositionType:kCCPositionTypeFree];
	[system setAnimation:anim2 withAnchorPoint:ccp(0.5f,0.0f)];
	[system setAnimationType:kCCParticleAnimationTypeOnce]; 
		
	[batchNode_ addChild: system z:10];
		
	
}



-(NSString *) title
{
	return @"LotsOfAnimatedParticles";
}

-(NSString*) subtitle
{
    return @"";
}

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelAtlas];
	
	uint count = 0; 
	CCNode* item;
	CCNode* batchNode = [self getChildByTag:2];
	CCARRAY_FOREACH(batchNode.children, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}
@end


#pragma mark -
#pragma mark App Delegate

// CLASS IMPLEMENTATIONS
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// When in iPhone RetinaDisplay, iPad, iPad RetinaDisplay mode, CCFileUtils will append the "-hd", "-ipad", "-ipadhd" to all loaded files
	// If the -hd, -ipad, -ipadhd files are not found, it will load the non-suffixed version
	[CCFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[CCFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "" (empty string)
	[CCFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene: scene];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}
@end


#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
	//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene:scene];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
#endif
