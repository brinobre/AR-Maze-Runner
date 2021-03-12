using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class ObjectPlacement : MonoBehaviour
{
    [SerializeField] ARRaycastManager arRaycastManager;
    [SerializeField] GameObject placementIndicator;
    [SerializeField] GameObject placementObject;
    [SerializeField] Rigidbody rb;
    [SerializeField] GameObject StartPostion;
    [SerializeField] GameObject PlaceButton;
    [SerializeField] GameObject ResetButton;


    private Pose placementPose;
    private bool placementPoseIsValid = false;
    private bool objectHasBeenPlaced = false;


    private void Start()
    {
        placementIndicator.SetActive(false);
        placementObject.SetActive(false);
        ResetButton.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        if (objectHasBeenPlaced) return;

        UpdatePlacementPose();
        UpdatePlacementIndicator();
    }

    public void PlaceObject()
    {


        if (!placementPoseIsValid)
        {
            return;
        }

        placementObject.transform.SetPositionAndRotation(placementIndicator.transform.position, placementIndicator.transform.rotation);
        placementObject.SetActive(true);
        placementIndicator.SetActive(false);

        objectHasBeenPlaced = true;
        ResetButton.SetActive(true);
        PlaceButton.SetActive(false);


    }

    public void ResetObject()
    {
        placementObject.SetActive(false);

        objectHasBeenPlaced = false;

        rb.transform.localPosition = StartPostion.transform.localPosition;
        rb.transform.localRotation = StartPostion.transform.localRotation;
        ResetButton.SetActive(false);
        PlaceButton.SetActive(true);

    }

    private void UpdatePlacementIndicator()
    {
        if (placementPoseIsValid)
        {
            placementIndicator.SetActive(true);
            placementIndicator.transform.SetPositionAndRotation(placementPose.position, placementPose.rotation);
        } else
        {
            placementIndicator.SetActive(false);
        }
    }

    private void UpdatePlacementPose()
    {
        var screenCenter = Camera.current.ViewportToScreenPoint(new Vector3(0.5f, 0.5f));
        var hits = new List<ARRaycastHit>();
        arRaycastManager.Raycast(screenCenter, hits, TrackableType.Planes);

        placementPoseIsValid = hits.Count > 0;
        if (placementPoseIsValid)
        {
            placementPose = hits[0].pose;
        }
    }
}
