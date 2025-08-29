# Trick-Or-Treat-Online Project Index

## Project Overview
A multiplayer Halloween-themed 2D platformer game built in Godot 4.4 where players can trick-or-treat at houses, collect candy, and customize their costumes.

## Project Structure

### Core Configuration
- **project.godot**: Main project configuration
  - Game name: "Trick-Or-Treat- Online!"
  - Version: 0.0.1
  - Main scene: Splash screen
  - Window size: 800x480
  - Autoload: PlayerGlobals

### Main Scenes

#### 1. Splash Scene (`Scenes/splash.tscn`)
- **Script**: `Assets/Scripts/splash.gd`
- **Purpose**: Main menu and multiplayer lobby
- **Features**:
  - Host/Join multiplayer functionality
  - Username input and costume selection
  - Ready system for all players
  - Background with animated clouds and moon
  - Audio: Splash theme music

#### 2. Stage Scene (`Scenes/stage.tscn`)
- **Script**: `Assets/Scripts/stage.gd`
- **Purpose**: Main gameplay area
- **Features**:
  - Parallax scrolling background (sky, clouds, moon, trees, houses)
  - Multiple house door triggers for trick-or-treating
  - Player spawning system
  - Audio: Main theme music

#### 3. Player Scene (`Scenes/player.tscn`)
- **Script**: `Assets/Scripts/player.gd`
- **Purpose**: Player character with multiplayer synchronization
- **Features**:
  - 2D platformer movement (left/right, jump)
  - Costume system with 12 different costumes
  - Camera following
  - Multiplayer sync for position, animation, and username

#### 4. Server Disconnect Scene (`Scenes/server_disconnect.tscn`)
- **Script**: `Assets/Scripts/server_disconnect.gd`
- **Purpose**: Handles disconnection and returns to splash screen

### Reusable Components

#### 1. Costume Select (`Components/costume_select.tscn`)
- **Script**: `Assets/Scripts/costume_select.gd`
- **Purpose**: Costume selection interface
- **Features**:
  - Left/right navigation through costumes
  - Visual costume preview
  - Integration with PlayerGlobals

#### 2. Candy Counter (`Components/candy_counter.tscn`)
- **Script**: `Assets/Scripts/candy_counter.gd`
- **Purpose**: Displays candy counts
- **Features**:
  - Dynamic text binding to PlayerGlobals values
  - Configurable source number property

#### 3. Player Sync Component (`Components/player_sync_component.tscn`)
- **Script**: `Assets/Scripts/player_sync_component.gd`
- **Purpose**: Handles player input and synchronization
- **Features**:
  - Movement input processing
  - Animation state management
  - Door interaction detection

#### 4. Label Sync Component (`Components/label_sync_component.tscn`)
- **Script**: `Assets/Scripts/label_sync_component.gd`
- **Purpose**: Synchronizes username labels in lobby
- **Features**:
  - Text synchronization
  - Ready state management

#### 5. Username Label (`Components/username_label.tscn`)
- **Script**: `Assets/Scripts/username_label.gd`
- **Purpose**: Displays player usernames in lobby
- **Features**:
  - Visual ready state indication (green outline)
  - Multiplayer authority handling

#### 6. Clouds (`Components/clouds.tscn`)
- **Script**: `Assets/Scripts/clouds.gd`
- **Purpose**: Animated background clouds
- **Features**:
  - Multiple cloud layers with different speeds
  - Infinite scrolling effect

### Core Scripts

#### PlayerGlobals (`Assets/Scripts/player_globals.gd`)
- **Type**: Autoload singleton
- **Purpose**: Global game state management
- **Features**:
  - Player data persistence (username, candy counts, costume)
  - Save/load system using JSON
  - Costume collection management (12 costumes)
  - Convenience functions for adding candy

#### Player (`Assets/Scripts/player.gd`)
- **Type**: CharacterBody2D
- **Purpose**: Main player character logic
- **Features**:
  - Platformer physics (gravity, jumping, movement)
  - Costume system integration
  - Door interaction and trick-or-treat tracking
  - Multiplayer authority handling

#### Splash (`Assets/Scripts/splash.gd`)
- **Type**: Node
- **Purpose**: Main menu and multiplayer lobby management
- **Features**:
  - ENet multiplayer networking (port 4139)
  - Host/Join functionality
  - Player lobby management
  - Ready system coordination
  - Scene transitions

#### Stage (`Assets/Scripts/stage.gd`)
- **Type**: Node
- **Purpose**: Main gameplay area management
- **Features**:
  - Player spawning system
  - Parallax background scrolling
  - Multiplayer peer management
  - Audio management

#### House Body (`Assets/Scripts/house_body.gd`)
- **Type**: Area2D
- **Purpose**: Door interaction detection
- **Features**:
  - Player proximity detection
  - Door trigger identification
  - Player state management

### Asset Organization

#### Audio Assets
- **Effects**: 25+ sound effects (doorbell, punches, costumes, etc.)
- **Music**: 10+ music tracks (main theme, splash theme, end themes)

#### Visual Assets
- **Backgrounds**: Sky, clouds, moon, trees, houses, sidewalks
- **Costumes**: 12 different costume sprites with animations
- **UI**: Menu elements, buttons, labels
- **Sprites**: Player animations, ToT elements, scrap elements

#### SpriteFrames
- **Costume Animations**: Individual sprite frame resources for each costume
- **Player Animations**: Base player animation frames

### Game Features

#### Multiplayer System
- **Networking**: ENet-based peer-to-peer networking
- **Synchronization**: Real-time player position, animation, and state sync
- **Lobby System**: Username display, ready states, costume preview
- **Connection Management**: Host/Join, disconnect handling

#### Costume System
- **12 Costumes**: Player, Clown, Cape, Ninja, Pants, Nipples, Faceless, Egg, Hole, Unibrow, Static, Witch Hat
- **Persistence**: Costume selection saved between sessions
- **Visual Feedback**: Real-time costume preview in lobby

#### Trick-or-Treat Mechanics
- **Door Interaction**: Multiple house doors with individual triggers
- **Progress Tracking**: Per-costume door completion tracking
- **Candy Collection**: Candy and candy corn counting system

#### Audio System
- **Background Music**: Different themes for different scenes
- **Sound Effects**: Interactive audio feedback
- **Looping**: Automatic music looping

#### Save System
- **Data Persistence**: JSON-based save file system
- **Stored Data**: Username, candy counts, costume progress
- **Auto-save**: Automatic saving on data changes

### Technical Implementation

#### Multiplayer Architecture
- **Authority System**: Each player controls their own character
- **Synchronization**: MultiplayerSynchronizer components for real-time sync
- **Spawn System**: MultiplayerSpawner for dynamic player creation
- **RPC System**: Remote procedure calls for game state coordination

#### Physics System
- **2D Platformer**: Gravity, jumping, collision detection
- **Character Movement**: Smooth left/right movement with animation states
- **Camera System**: Player-following camera with limits

#### UI System
- **Dynamic Labels**: Real-time text updates from global state
- **Button Integration**: Custom button styling and functionality
- **Visual Feedback**: Ready states, costume selection indicators

### Development Notes

#### Godot Version
- **Engine**: Godot 4.4
- **Features**: Forward Plus rendering
- **Format**: Scene format 3

#### Performance Considerations
- **Parallax Scrolling**: Efficient background movement
- **Sprite Optimization**: Texture filtering and scaling
- **Audio Management**: Distance-based audio attenuation

#### Code Organization
- **Component-Based**: Reusable scene components
- **Singleton Pattern**: Global state management
- **Event-Driven**: Signal-based communication
- **Modular Design**: Separated concerns across scripts

This project demonstrates a complete multiplayer game implementation in Godot with networking, persistence, audio, and visual systems working together to create an engaging trick-or-treat experience.
