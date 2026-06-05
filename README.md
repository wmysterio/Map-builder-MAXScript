# Map builder (MAXScript)

This script generates roads and sidewalks. The script's default settings roughly match the road settings in GTA: San Andreas. You can experiment and find the best option for your project. The script automates a lot of the work, but manual editing is unavoidable! Use the script to create a prototype city for the game.

## Requirements:
- Autodesk 3ds Max 2026 (other versions have not been tested).

## Usage

Move the file `map_builder.ms` from the archive to any location. Go to the menu `Scripting->Run Script...` and select the file "map_builder.ms".

![](https://github.com/user-attachments/assets/70af4ca8-8f11-452a-b782-759abe990192)

All you need to do is create a plane and place the edges along the road trajectory.

![](https://github.com/user-attachments/assets/0be36bef-10b0-433a-892f-597d3c71335e)

Select the object and click the `Generate Map` button and wait for the process to complete.

![](https://github.com/user-attachments/assets/0b4d24ba-9520-43a5-bc75-b5bf4b422761)

## Recommendations:

- Try not to place vertices too close to each other.
- Maintain a balance between edge angles.
- All vertices must have at least two edges.
- The lower part of the utility contains auxiliary tools that will allow better control of the positions of the vertices.
