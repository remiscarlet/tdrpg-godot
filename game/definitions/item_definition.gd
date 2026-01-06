extends DefinitionBase
class_name ItemDefinition

enum ItemKind { RESOURCE, CONSUMABLE, KEY_ITEM }

@export var kind: ItemKind = ItemKind.RESOURCE
@export var stack_max: int = 99