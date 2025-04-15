using UnityEngine;
using UnityEngine.Rendering;

public class ScrollAndPinch : MonoBehaviour
{
#if UNITY_IOS || UNITY_ANDROID
    public Camera mainCamera;
    protected Plane plane;

    private void Start()
    {
        if (mainCamera == null)
        {
            mainCamera = Camera.main;
        }
    }

    private void Update()
    {
        if (Input.touchCount >= 1)
        {
            plane.SetNormalAndPosition(transform.up, transform.position);
        }

        var Delta1 = Vector3.zero;
        var Delta2 = Vector3.zero;

        //Scroll
        if (Input.touchCount >= 1)
        {
            Delta1 = PlanePositionDelta(Input.GetTouch(0));
            if (Input.GetTouch(0).phase == TouchPhase.Moved)
            {
                mainCamera.transform.Translate(Delta1, Space.World);
            }
        }

        //Pinch
        if (Input.touchCount >= 2)
        {
            var pos1Before = PlanePosition(Input.GetTouch(0).position - Input.GetTouch(0).deltaPosition);
            var pos2Before = PlanePosition(Input.GetTouch(1).position - Input.GetTouch(1).deltaPosition);
            var pos1 = PlanePosition(Input.GetTouch(0).position);
            var pos2 = PlanePosition(Input.GetTouch(1).position);

            // calc zoom
            var zoom = Vector3.Distance(pos1, pos2) / Vector3.Distance(pos1Before, pos2Before);

            // edge case
            if (zoom == 0 || zoom > 10)
            {
                return;
            }
            // Move cam amount the mid ray
            mainCamera.transform.position = Vector3.LerpUnclamped(pos1, mainCamera.transform.position, 1 / zoom);

            if (pos2 != pos2Before)
            {
                mainCamera.transform.RotateAround(pos1, plane.normal, Vector3.SignedAngle(pos2 - pos1, pos2Before - pos1Before, plane.normal));
            }
        }
    }

    protected Vector3 PlanePositionDelta(Touch touch)
    {
        // not moved
        if (touch.phase != TouchPhase.Moved)
        {
            return Vector3.zero;
        }

        var rayBefore = mainCamera.ScreenPointToRay(touch.position - touch.deltaPosition);
        var rayNow = mainCamera.ScreenPointToRay(touch.position);
        if (plane.Raycast(rayBefore, out var enterBefore) && plane.Raycast(rayNow, out var enterNow))
        {
            return rayBefore.GetPoint(enterBefore) - rayNow.GetPoint(enterNow);
        }

        return Vector3.zero;
    }
    protected Vector3 PlanePosition(Vector2 screenPos)
    {
        var rayNow = mainCamera.ScreenPointToRay(screenPos);
        if (plane.Raycast(rayNow, out var enter))
        {
            return rayNow.GetPoint(enter);
        }
        return Vector3.zero;
    }
#endif
}
