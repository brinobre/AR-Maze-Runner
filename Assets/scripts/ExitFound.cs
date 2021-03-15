using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ExitFound : MonoBehaviour
{    

    [SerializeField] GameObject ResetButton;
    [SerializeField] GameObject FinishPanel;

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            FinishPanel.SetActive(true);
        }
    }

    public void Restart()
    {
        SceneManager.LoadScene("SampleScene");
        FinishPanel.SetActive(false);
    }
}
