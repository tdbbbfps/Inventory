<img src="addons/godotinventory/icon.svg" title="" alt="icon" data-align="center">

# Godot Inventory

This is a simple grid inventory system written in GDScript.

Provide grid inventory system base on slot.

Drag and drop, swap items between slots.

## Features:

1. Drag and drop item:
   
   * Drop item on empty slot.
   
   * Stack item on slot.
   
   * Swap item with another slow.

2. Popup tooltip:
   
   * Show item information when cursor enter slot.

3. Inventory sorting:
   
   * Sort inventory by name in ascending or descending order.

4. Persistent:
   
   * Save and load inventory data with custom resource.
   
   * Automatically save inventory data when exiting the game.

## Usage:

1. Add a CanvasLayer in your player character and add inventory in CanvasLayer.

2. Add an Area2D + CollisionShape2D and CollectItemComponenet in player character.

3. Set up dependencies (Inventory, CollectItemComponent).

## Installation:

1. Clone or download this repositoey. (Or install from asset library.)

2. Copy the entire the addons/godotinventory folder into your project.

3. Enable the plugin.
