import numpy as np

from anchor import Anchor

class Tag:
    def __init__(self, tag_id=None, name=None, anchor_list=None):
        self.tag_id = tag_id
        self.name = name
        self.position = None
        self.anchor_list = anchor_list if anchor_list is not None else []  # Ensure it's always a list

    def update(self, tag_id = None, name=None,  anchor_distance_list = None):
        if tag_id: 
            self.tag_id = tag_id
        if name:
            self.name = name
        if anchor_distance_list:
            for name, value in anchor_distance_list.items():
                anchor = next((anchor for anchor in self.anchor_list if anchor.name == name), None)
                if anchor:
                    anchor.update_distance(value)
                else:
                    print(f"Anchor {name} not found in tag {self.name}")
                    
    def add_anchor(self, anchor):
        if isinstance(anchor, Anchor):
            self.anchor_list.append(anchor)
        else:
            print("Invalid anchor object")
            
    def calculate_position(self):
        """
        Calculate the position of the tag based on the anchor list.
        This is a placeholder for the actual position calculation logic.
        View algorithm here: https://www.sciencedirect.com/science/article/pii/S2665917424000977?via%3Dihub
        """

        if len(self.anchor_list) < 3:
            print("Not enough anchors to calculate position")
            return None
        
        available_anchors = [anchor for anchor in self.anchor_list if anchor.distance_to_tag is not None]
        
        if not available_anchors:
            print("No available anchors with distance data")
            return None
        
        # Construct the ref anchor
        ref_anchor = available_anchors[-1]
        
        a_vectors = []
        b_vectors = []
        
        for anchor in available_anchors[:-1]:
            a_vectors.append((2*(anchor.x - ref_anchor.x), 2*(anchor.y - ref_anchor.y)))
            b_vectors.append((anchor.x**2 - ref_anchor.x**2) + (anchor.y**2 - ref_anchor.y**2) + (ref_anchor.distance_to_tag**2 - anchor.distance_to_tag**2))
        
        a_vectors = np.array(a_vectors)
        b_vectors = np.array(b_vectors)
        
        try:
            position = np.linalg.lstsq(a_vectors, b_vectors, rcond=None)[0]  # Solve for x (position)
            self.position = (float(round(position[0], 1)), float(round(position[1], 1)))
            return self.position
        except np.linalg.LinAlgError as e:
            print(f"Error calculating position: {e}")
            return None
        
    def reset(self):
        # self.tag_id = None
        self.position = None
        for anchor in self.anchor_list:
            anchor.reset()