abstract class IActivityRepository {
  Future<List<Activity>> getActivities();
  Future<Activity> getActivity(String id);
  Future<void> addActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(String id);
}

class Activity {}
