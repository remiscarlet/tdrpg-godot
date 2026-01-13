class_name ItemDefinition
extends DefinitionBase

enum ItemKind { RESOURCE, CONSUMABLE, KEY_ITEM }

@export var kind: ItemKind = ItemKind.RESOURCE
@export var stack_max: int = 99
