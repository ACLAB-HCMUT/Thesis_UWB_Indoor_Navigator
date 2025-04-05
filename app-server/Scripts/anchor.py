class Anchor:
    def __init__(self, id = None, name = None, x=None, y=None, distance_to_tag=None):
        self.id = id
        self.name = name
        self.x = x
        self.y = y
        self.distance_to_tag = distance_to_tag
        
    def update_distance(self, distance):
        self.distance_to_tag = distance
        
    def reset(self):
        self.distance_to_tag = None