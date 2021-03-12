using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;


public class ARPlaceObject : MonoBehaviour
{
    [SerializeField] private GameObject arPrefab;
    [SerializeField] private ARRaycastManager arRaycastManager;
    [SerializeField] private PlaneDetectionToggle planeManager;
    [SerializeField] Text PlaceButtonTxt;


    private Vector2 touchPos;

    List<ARRaycastHit> hits = new List<ARRaycastHit>();
    private bool objectPlaced = false;

    private void Awake()
    {
        if (!arRaycastManager) arRaycastManager = FindObjectOfType<ARRaycastManager>();
    }

    // Update is called once per frame
    void Update()
    {
        if(objectPlaced == true)
        {
            planeManager.TogglePlaneDetection();
            return;
        }

        if (!TryGetTouchPos()) return;

        if(arRaycastManager.Raycast(touchPos, hits, TrackableType.PlaneWithinPolygon))
        {
            var hitPose = hits[0].pose;
            arPrefab.SetActive(true);
            arPrefab.transform.position = hitPose.position;
            objectPlaced = true;
        }


    }

    private bool TryGetTouchPos()
    {
         if(Input.touchCount > 0)
        {
            touchPos = Input.GetTouch(0).position;
            return true;
        }
        return false;
    }
}
