class Anchor:
    def __init__(self, id = None, name = None, x=None, y=None, distance_to_tag=None, current_update_method=None):
        self.id = id
        self.name = name
        self.x = x
        self.y = y
        self.distance_to_tag = distance_to_tag
        self.current_update_method = current_update_method
        
    def update_htpps_method(self, x=None, y=None, current_update_method=None):
        if x:
            self.x = x
        if y:
            self.y = y
        if current_update_method:
            self.current_update_method = current_update_method
        
    def update_distance(self, distance):
        self.distance_to_tag = distance
        
    def reset(self):
        self.distance_to_tag = None
    
    def reset_htpps_method(self):
        self.current_update_method = None