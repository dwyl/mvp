from locust import HttpUser, task

class Item(HttpUser):
    @task
    def get_item(self):
        self.client.get("/api/items/1")
