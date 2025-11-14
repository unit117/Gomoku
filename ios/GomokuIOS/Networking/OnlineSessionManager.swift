import Foundation
import MultipeerConnectivity

protocol OnlineSessionDelegate: AnyObject {
    func sessionDidUpdate(board: GomokuBoard, status: String, highlights: [BoardPoint])
    func sessionDidFinish(result: GameResult)
    func sessionDiscoveryStateChanged(isDiscovering: Bool)
    func sessionDidReceiveUndoRequest()
}

final class OnlineSessionManager: NSObject {
    weak var delegate: OnlineSessionDelegate?
    private(set) var board = GomokuBoard()
    private let serviceType = "gomoku-online"
    private let localPeer: MCPeerID
    private lazy var session = MCSession(peer: localPeer, securityIdentity: nil, encryptionPreference: .required)
    private lazy var advertiser = MCNearbyServiceAdvertiser(peer: localPeer, discoveryInfo: nil, serviceType: serviceType)
    private lazy var browser = MCNearbyServiceBrowser(peer: localPeer, serviceType: serviceType)
    private var isHost: Bool = false
    private var currentTurn: StonePlayer = .black
    private var assignedPlayer: StonePlayer = .black

    var canSendUndoRequest: Bool {
        return board.moves.count >= 2
    }

    var isLocalTurn: Bool {
        currentTurn == assignedPlayer
    }

    init(playerID: String) {
        self.localPeer = MCPeerID(displayName: playerID)
        super.init()
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }

    func start() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        delegate?.sessionDiscoveryStateChanged(isDiscovering: true)
    }

    func stop() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
        delegate?.sessionDiscoveryStateChanged(isDiscovering: false)
    }

    func placeStone(point: BoardPoint) {
        guard isLocalTurn else { return }
        guard board.placeStone(at: point, player: currentTurn) else { return }
        send(message: .move(point))
        let movingPlayer = currentTurn
        currentTurn = currentTurn.opponent
        updateStatus()
        if board.hasWin(for: movingPlayer) {
            finish(result: .win)
        }
    }

    func requestUndo() {
        send(message: .undoRequest)
    }

    func resign() {
        finish(result: .loss)
        send(message: .resign)
    }

    func respondToUndoRequest(accepted: Bool) {
        if accepted {
            _ = board.undoLastMove()
            _ = board.undoLastMove()
            currentTurn = board.moves.last?.player.opponent ?? .black
        }
        updateStatus()
        send(message: .undoResponse(accepted))
    }

    private func updateStatus(message: String? = nil) {
        let status = message ?? (currentTurn == .black ? "Black to move" : "White to move")
        let snapshot = board
        DispatchQueue.main.async {
            self.delegate?.sessionDidUpdate(board: snapshot,
                                            status: status,
                                            highlights: snapshot.moves.suffix(2).map { $0.position })
        }
    }

    private func finish(result: GameResult) {
        DispatchQueue.main.async {
            self.delegate?.sessionDidFinish(result: result)
        }
    }

    private func send(message: SessionMessage) {
        guard !session.connectedPeers.isEmpty, let data = try? JSONEncoder().encode(message) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}

extension OnlineSessionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.delegate?.sessionDiscoveryStateChanged(isDiscovering: state == .connecting)
        }
        if state == .connected, let remote = session.connectedPeers.first {
            isHost = localPeer.displayName < remote.displayName
            assignedPlayer = isHost ? .black : .white
            currentTurn = .black
            updateStatus()
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(SessionMessage.self, from: data) else { return }
        DispatchQueue.main.async {
            self.handle(message: message)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension OnlineSessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertising error: \(error.localizedDescription)")
    }
}

extension OnlineSessionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browsing error: \(error.localizedDescription)")
    }
}

private enum SessionMessage: Codable {
    case move(BoardPoint)
    case undoRequest
    case undoResponse(Bool)
    case resign
}

private extension OnlineSessionManager {
    func handle(message: SessionMessage) {
        switch message {
        case .move(let point):
            let movingPlayer = currentTurn
            _ = board.placeStone(at: point, player: movingPlayer)
            if board.hasWin(for: movingPlayer) {
                finish(result: .loss)
            }
            currentTurn = currentTurn.opponent
            updateStatus()
        case .undoRequest:
            updateStatus(message: "Opponent requested a retract")
            delegate?.sessionDidReceiveUndoRequest()
        case .undoResponse(let accepted):
            if accepted {
                _ = board.undoLastMove()
                _ = board.undoLastMove()
                currentTurn = board.moves.last?.player.opponent ?? .black
                updateStatus()
            } else {
                updateStatus()
            }
        case .resign:
            finish(result: .win)
        }
    }
}
