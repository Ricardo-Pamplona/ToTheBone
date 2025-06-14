extends Node

class PriorityQueue:
	var elements = []

	func push(item, priority):
		elements.append({ "item": item, "priority": priority })
		elements.sort_custom(func(a, b): return a["priority"] < b["priority"])

	func pop():
		return elements.pop_front()["item"]

	func is_empty():
		return elements.is_empty()
