using UnityEngine;

[ExecuteAlways]
public class RayMarchShapeController : MonoBehaviour
{
    /// <summary>/ This component is responsible for passing the position and scale of the shape to the shader.
    /// The shader will then use this information to correctly position and scale the shape in the scene.
    /// </summary>
    [SerializeField]Renderer _renderer;
    MaterialPropertyBlock _mpb;

    static readonly int PositionOffsetID = Shader.PropertyToID("_Pos_Offset");
    static readonly int OverallScaleID   = Shader.PropertyToID("_OverallScale");

    private void OnEnable() {
        if (_renderer == null) _renderer = GetComponent<Renderer>();
        if (_mpb == null) _mpb = new MaterialPropertyBlock();
    }
    void Update()
    {
        if (_renderer == null) return;

        _renderer.GetPropertyBlock(_mpb);

        float baseScale = _renderer.sharedMaterial.GetFloat(OverallScaleID);

        _mpb.SetVector(PositionOffsetID, transform.position * 0.5f);
        _mpb.SetFloat(OverallScaleID,    baseScale * transform.localScale.x);

        _renderer.SetPropertyBlock(_mpb);
    }
}
