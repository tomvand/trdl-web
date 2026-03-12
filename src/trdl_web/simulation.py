class Simulation:
    def __init__(self):
        self.x = 0

    def generate_svg(self):
        return f"""
<svg width="200" height="80" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="40" width="180" height="10" fill="black"/>
  <circle cx="{10 + self.x}" cy="45" r="6" fill="red"/>
</svg>
"""

    def step(self):
        self.x += 2
        if self.x > 160:
            self.x = 0
