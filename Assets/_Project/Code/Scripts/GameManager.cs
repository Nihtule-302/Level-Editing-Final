using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    // ── Singleton ────────────────────────────────────────────────────────────

    private static GameManager _instance;
    public static GameManager Instance
    {
        get
        {
            if (_instance == null)
                _instance = FindObjectOfType<GameManager>();
            return _instance;
        }
    }

    // ── Inspector Fields ─────────────────────────────────────────────────────

    [Header("References")]
    [SerializeField] private GameObject _player;
    [SerializeField] private GameObject _winScreen;

    [Header("Death Settings")]
    [SerializeField] private float _deathHeight = -229.7462f;
    [SerializeField] private bool _drawGizmos = true;

    // ── Unity Callbacks ──────────────────────────────────────────────────────

    private void Start()
    {
        _winScreen.SetActive(false);
    }

    private void Update()
    {
        if (_player.transform.position.y < _deathHeight)
            ResetGame();

        if (Keyboard.current == null)
        {
            Debug.LogWarning("Keyboard.current is NULL");
            return;
        }

        if (Keyboard.current.escapeKey.wasPressedThisFrame)
        {
            Debug.Log("Escape pressed");
            QuitGame();
        }
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        if (!_drawGizmos) return;

        Gizmos.color = Color.red;
        Gizmos.DrawCube(new Vector3(0, _deathHeight, 0), new Vector3(1000, 1, 200));
    }
#endif

    // ── Public API ───────────────────────────────────────────────────────────

    public void ResetGame()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public void QuitGame()
    {
    #if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
    #else
        Application.Quit();
    #endif
    }

    public void WinGame()
    {
        WinGameAsync().Forget();
    }

    // ── Private Methods ──────────────────────────────────────────────────────

    private async UniTaskVoid WinGameAsync()
    {
        _winScreen.SetActive(true);
        await UniTask.Delay(3000, cancellationToken: this.GetCancellationTokenOnDestroy());
        ResetGame();
    }
}