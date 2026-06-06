# Map Builder (MAXScript)

This script generates roads and sidewalks. The default settings are roughly based on the road parameters used in GTA: San Andreas. Feel free to experiment and find the settings that work best for your project.

The script automates a significant portion of the work, but some manual editing is still required. It is best used for creating a prototype city layout for a game.

## Requirements

* Autodesk 3ds Max 2026 (other versions have not been tested).

## Usage

Extract the file `map_builder.ms` from the archive and place it in any convenient location. In 3ds Max, go to `Scripting → Run Script...` and select `map_builder.ms`.

![](https://github.com/user-attachments/assets/06b3a333-1749-4ee7-857b-c0c6e1b2dd9b)

Create a plane and position its edges along the desired road layout.

![](https://github.com/user-attachments/assets/0be36bef-10b0-433a-892f-597d3c71335e)

Select the object, click the `Generate Map` button, and wait for the process to finish.

![](https://github.com/user-attachments/assets/1af68625-093f-4a65-af90-1acad868c24a)

## Recommendations

* Avoid placing vertices too close to each other.
* Maintain reasonable angles between connected edges.
* Every vertex must be connected to at least two edges.
* The lower section of the utility contains additional tools that help you control vertex positions more precisely.
