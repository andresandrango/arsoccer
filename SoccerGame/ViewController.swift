//
//  ViewController.swift
//  SoccerGame
//
//  Created by Andres Andrango on 7/2/22.
//

import UIKit
import RealityKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    let fieldWidth: Float = 3.0
    let fieldDepth: Float = 6.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.20, 0.20])
        
        arView.scene.addAnchor(anchor)
        
        let fieldMeshPlane = MeshResource.generatePlane(width: fieldWidth, depth: fieldDepth)
//        let fieldMaterial = SimpleMaterial(color: .green, isMetallic: false)
        var fieldMaterial = SimpleMaterial()
        fieldMaterial.color = .init(
            tint: .white.withAlphaComponent(0.99),
            texture: .init(try! .load(named: "grass01")))
        
        let fieldModel: Entity = ModelEntity(mesh: fieldMeshPlane, materials: [fieldMaterial])
        
        // fieldModel.generateCollisionShapes(recursive: true)
        
        fieldModel.position = [0, 1, 0]
        
        anchor.addChild(fieldModel)
        
        var cancellable: AnyCancellable? = nil
        
        cancellable = ModelEntity.loadModelAsync(named: "toy_drummer")
            .append(ModelEntity.loadModelAsync(named: "toy_robot_vintage"))
            .collect()
            .sink(receiveCompletion: {error in
                cancellable?.cancel()
            }, receiveValue: {entities in
                var players: [ModelEntity] = []
                
                let playerA = entities[0]
                let playerB = entities[1]
                
                for entity in entities {
                    entity.setScale([0.01, 0.01, 0.01], relativeTo: anchor)
                }
                
                for _ in 1...11 {
                    let playerAInstance = playerA.clone(recursive: true)
                    players.append(playerAInstance)
                    playerAInstance.transform.rotation = simd_quatf(angle: Float.pi, axis: [0, 1, 0])
                    
                    players.append(playerB.clone(recursive: true))
                }
                
                for player in players {
                    fieldModel.addChild(player)
                    player.transform.translation.x += Float.random(in: -self.fieldWidth/2..<self.fieldWidth/2)
                    player.transform.translation.z += Float.random(in: -self.fieldDepth/2..<self.fieldDepth/2)
                }
            })
        
        
        
    }
}
